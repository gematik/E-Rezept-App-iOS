require 'json'
require 'pathname'
require 'erb'

class SwiftErrorParser
  def initialize(sources_dir)
    @sources_dir = sources_dir
    @errors = []
    @files_with_errors = []
  end

  # Phase 1: Find all files containing @CodedError
  def find_coded_error_files
    Dir.glob("#{@sources_dir}/**/*.swift").each do |file_path|
      content = File.read(file_path)
      if content.include?('@CodedError')
        @files_with_errors << {
          path: file_path,
          content: content
        }
      end
    end
  end

  # Phase 2: Parse each file and extract all @CodedError declarations
  def parse_files
    @files_with_errors.each do |file_info|
      parse_single_file(file_info)
    end
  end

  def get_errors
    @errors
  end

  def get_summary
    {
      total_files: @files_with_errors.length,
      total_enums: @errors.length,
      total_cases: @errors.sum { |e| e[:cases].length }
    }
  end

  private

  def parse_single_file(file_info)
    content = file_info[:content]
    lines = content.lines
    
    # Find all @CodedError positions
    coded_error_positions = []
    content.scan(/@CodedError\("(\d+)"\)/) do |match|
      code = match[0]
      position = Regexp.last_match.begin(0)
      line_number = content[0...position].count("\n") + 1
      
      coded_error_positions << {
        code: code,
        position: position,
        line_number: line_number
      }
    end
    
    # Process each @CodedError
    coded_error_positions.each do |coded_error|
      process_coded_error(file_info, coded_error, content, lines)
    end
  end

  def process_coded_error(file_info, coded_error, content, lines)
    # Extract text from @CodedError position to end of file
    remaining_content = content[coded_error[:position]..-1]
    
    # Find the enum declaration
    enum_match = remaining_content.match(
      /@CodedError\("#{coded_error[:code]}"\)\s*
      (?:@\w+[^@\n]*\s*)*     # Optional other attributes like @CasePathable
      (?:public\s+)?          # Optional public keyword
      enum\s+                 # enum keyword
      ([`\w.]+)               # enum name (with backticks and dots for nested)
      \s*:\s*                 # colon
      (?:[^{]*,\s*)?          # Optional other protocols like Equatable
      (?:Swift\.)?Error       # Error protocol
      [^{]*                   # Any other content before opening brace
      \{                      # Opening brace
      /mx
    )
    
    unless enum_match
      return
    end
    
    enum_name = enum_match[1]
    enum_start_pos = coded_error[:position] + enum_match.begin(0)
    body_start_pos = coded_error[:position] + enum_match.end(0)
    
    # Find the complete enum body using proper brace matching
    body_end_pos = find_matching_brace(content, body_start_pos - 1) # -1 because we want position of opening brace
    
    unless body_end_pos
      return
    end
    
    enum_body = content[body_start_pos...body_end_pos]
    
    # Extract preceding documentation
    documentation = extract_preceding_documentation(content, coded_error[:position])
    
    # Determine if this is a nested enum
    containing_structure = find_containing_structure(content, coded_error[:position])
    qualified_name = containing_structure ? "#{containing_structure}.#{enum_name}" : enum_name
    
    # Create error entry
    error_info = {
      code: coded_error[:code],
      name: enum_name,
      qualified_name: qualified_name,
      file: file_info[:path],
      line: coded_error[:line_number],
      documentation: documentation,
      body: enum_body,
      start_pos: enum_start_pos,
      end_pos: body_end_pos,
      cases: []
    }
    
    # Extract cases
    extract_cases(error_info, enum_body, body_start_pos)
    
    @errors << error_info
  end

  def find_matching_brace(content, open_brace_pos)
    brace_count = 1
    pos = open_brace_pos + 1
    in_string = false
    in_line_comment = false
    in_block_comment = false
    
    while pos < content.length && brace_count > 0
      char = content[pos]
      
      # Handle string literals
      if !in_line_comment && !in_block_comment
        if char == '"' && (pos == 0 || content[pos - 1] != '\\')
          in_string = !in_string
          pos += 1
          next
        end
      end
      
      # Skip everything inside strings
      if in_string
        pos += 1
        next
      end
      
      # Handle comments
      if !in_line_comment && !in_block_comment && char == '/'
        next_char = pos + 1 < content.length ? content[pos + 1] : nil
        if next_char == '/'
          in_line_comment = true
          pos += 2
          next
        elsif next_char == '*'
          in_block_comment = true
          pos += 2
          next
        end
      end
      
      # Handle end of line comment
      if in_line_comment && char == "\n"
        in_line_comment = false
        pos += 1
        next
      end
      
      # Handle end of block comment
      if in_block_comment && char == '*' && pos + 1 < content.length && content[pos + 1] == '/'
        in_block_comment = false
        pos += 2
        next
      end
      
      # Skip brace counting inside comments
      if in_line_comment || in_block_comment
        pos += 1
        next
      end
      
      # Count braces only when not in comments or strings
      case char
      when '{'
        brace_count += 1
      when '}'
        brace_count -= 1
      end
      
      pos += 1
    end
    
    brace_count == 0 ? pos - 1 : nil
  end

  def extract_preceding_documentation(content, coded_error_pos)
    lines_before = content[0...coded_error_pos].lines
    documentation_lines = []
    
    # Look backwards from the @CodedError position
    line_index = lines_before.length - 2 # -1 for 0-indexing, -1 more to skip the @CodedError line
    
    while line_index >= 0
      line = lines_before[line_index].strip
      
      if line.start_with?('///')
        documentation_lines.unshift(line.sub(/^\/\/\/\s?/, ''))
      elsif line.start_with?('//')
        documentation_lines.unshift(line.sub(/^\/\/\s?/, ''))
      elsif line.empty?
        # Allow empty lines, but only if we already have documentation
        if documentation_lines.any?
          documentation_lines.unshift('')
        end
      else
        # Hit non-comment, non-empty line
        break
      end
      
      line_index -= 1
    end
    
    # Clean up leading/trailing empty lines
    while documentation_lines.first&.empty?
      documentation_lines.shift
    end
    while documentation_lines.last&.empty?
      documentation_lines.pop
    end
    
    documentation_lines.join("\n")
  end

  def find_containing_structure(content, position)
    # Look backwards to find containing struct/class/enum
    before_content = content[0...position]
    
    # Find all struct/class/enum/extension declarations before this position
    structures = []
    
    before_content.scan(/(?:public\s+)?(?:struct|class|enum|extension)\s+([`\w.]+)/) do |match|
      structure_name = match[0]
      match_start = Regexp.last_match.begin(0)
      match_end = Regexp.last_match.end(0)
      
      # Find the opening brace for this structure
      after_match = content[match_end..-1]
      if brace_match = after_match.match(/\s*[^{]*\{/)
        structure_start = match_end + brace_match.end(0)
        structure_end = find_matching_brace(content, structure_start - 1)
        
        if structure_end && position >= structure_start && position <= structure_end
          structures << {
            name: structure_name,
            start: structure_start,
            end: structure_end,
            declaration_pos: match_start
          }
        end
      end
    end
    
    # Return the innermost containing structure (most recent declaration position)
    innermost = structures.max_by { |s| s[:declaration_pos] }
    
    if innermost
      # Handle backticks in names
      innermost[:name].gsub(/`([^`]+)`/, '\1')
    else
      nil
    end
  end

  def extract_cases(error_info, body, body_start_pos)
    # First find all nested @CodedError ranges within this body
    nested_ranges = []
    body.scan(/@CodedError\("(\d+)"\)/) do |match|
      nested_code = match[0]
      nested_pos = Regexp.last_match.begin(0)
      
      # Skip if this is the current enum's own @CodedError
      next if nested_code == error_info[:code]
      
      # Find the enum declaration for this nested @CodedError
      remaining_body = body[nested_pos..-1]
      enum_match = remaining_body.match(
        /@CodedError\("#{nested_code}"\)\s*
        (?:@\w+[^@\n]*\s*)*     # Optional other attributes
        (?:public\s+)?          # Optional public keyword
        enum\s+                 # enum keyword
        ([`\w.]+)               # enum name
        \s*:\s*                 # colon
        (?:Swift\.)?Error       # Error protocol
        [^{]*                   # Any other content before opening brace
        \{                      # Opening brace
        /mx
      )
      
      if enum_match
        enum_start = nested_pos + enum_match.end(0)
        # Use the body start position to find the actual position in the full content
        full_open_brace_pos = body_start_pos + enum_start - 1
        
        # Find matching brace in the full content
        full_content = File.read(error_info[:file])
        enum_end = find_matching_brace(full_content, full_open_brace_pos)
        
        if enum_end
          # Convert back to relative position within the body
          body_enum_end = enum_end - body_start_pos
          nested_ranges << [enum_start, body_enum_end]
        end
      end
    end
    
    # Find all @ErrorCode cases that are NOT inside nested enum ranges
    body.scan(/@ErrorCode\("(\d+)"\)/) do |match|
      error_code = match[0]
      error_code_pos = Regexp.last_match.begin(0)
      
      # Check if this @ErrorCode is inside any nested enum range
      is_nested = nested_ranges.any? do |start_pos, end_pos|
        error_code_pos >= start_pos && error_code_pos <= end_pos
      end
      
      # Skip if this case is inside a nested enum
      next if is_nested
      
      # Extract the case declaration that follows
      remaining_body = body[error_code_pos..-1]
      
      # Match the case pattern
      case_match = remaining_body.match(
        /@ErrorCode\("#{error_code}"\)\s*
        (?:\/\/\/[^\n]*\n\s*)*       # Optional documentation comments
        (?:\/\/[^\n]*\n\s*)*         # Optional regular comments
        case\s+                      # case keyword
        ([`\w]+)                     # case name (with backticks)
        (?:\(([^)]*)\))?             # Optional associated values (captured)
        /mx
      )
      
      if case_match
        case_name = case_match[1]
        associated_values = case_match[2]
        
        # Parse associated types from the associated values
        assoc_types = []
        if associated_values && !associated_values.strip.empty?
          # Split by comma and extract type names
          associated_values.split(',').each do |assoc_val|
            # Extract type name (remove parameter names, labels, etc.)
            # Match patterns like "LocalStoreError", "error: Swift.Error", "FHIRClient.Error"
            type_match = assoc_val.strip.match(/(?:\w+:\s*)?([A-Za-z_][A-Za-z0-9_.]*(?:\.Error|Error|\.Error)?)/)
            if type_match
              assoc_types << type_match[1]
            end
          end
        end
        
        # Extract preceding comments for this case
        case_documentation = extract_case_documentation(body, error_code_pos)
        
        # Generate full error ID
        full_id = "#{error_info[:code]}#{error_code.rjust(2, '0')}"
        
        case_info = {
          code: error_code,
          full_id: full_id,
          name: case_name,
          documentation: case_documentation,
          qualified_name: "#{error_info[:qualified_name]}.#{case_name}",
          assoc_types: assoc_types
        }
        
        error_info[:cases] << case_info
      end
    end
  end

  def extract_case_documentation(body, error_code_pos)
    lines_before = body[0...error_code_pos].lines
    documentation_lines = []
    
    # Look backwards from the @ErrorCode position
    line_index = lines_before.length - 1 # Start from the line before @ErrorCode
    
    while line_index >= 0
      line = lines_before[line_index].strip
      
      if line.start_with?('///')
        documentation_lines.unshift(line.sub(/^\/\/\/\s?/, ''))
      elsif line.start_with?('//')
        documentation_lines.unshift(line.sub(/^\/\/\s?/, ''))
      elsif line.empty?
        # Allow empty lines
        if documentation_lines.any?
          documentation_lines.unshift('')
        end
      else
        # Hit non-comment, non-empty line (probably previous case)
        break
      end
      
      line_index -= 1
    end
    
    # Clean up leading/trailing empty lines
    while documentation_lines.first&.empty?
      documentation_lines.shift
    end
    while documentation_lines.last&.empty?
      documentation_lines.pop
    end
    
    documentation_lines.join("\n")
  end

  def escape_html(str)
    str.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;').gsub("'", '&#39;')
  end
end

module Fastlane
  module Actions
    class GenerateErrorDocumentationAction < Action
      def self.run(params)
        sources_dir = params[:sources_dir]
        output_dir = params[:output_dir]

        # Create output directory if it doesn't exist
        FileUtils.mkdir_p(output_dir)

        # Initialize the sophisticated parser
        parser = SwiftErrorParser.new(sources_dir)
        
        # Phase 1: Find all files containing @CodedError
        UI.message "🔍 Finding all files with @CodedError annotations..."
        parser.find_coded_error_files
        
        # Phase 2: Parse each file and extract all @CodedError declarations  
        UI.message "⚙️ Parsing error declarations..."
        parser.parse_files
        
        errors = parser.get_errors
        summary = parser.get_summary
        
        UI.success "📊 Found #{summary[:total_enums]} error enums with #{summary[:total_cases]} total cases"

        # Convert to the format expected by the rest of the action
        all_errors = []
        all_cases = []

        errors.each do |error_info|
          # Convert cases to expected format
          converted_cases = error_info[:cases].map do |case_info|
            {
              error_code: case_info[:code],
              full_id: case_info[:full_id],
              name: case_info[:name],
              enum_name: error_info[:name],
              qualified_enum_name: error_info[:qualified_name],
              qualified_case_name: case_info[:qualified_name],
              documentation: case_info[:documentation],
              file: error_info[:file],
              assoc_types: case_info[:assoc_types] || []
            }
          end

          all_cases.concat(converted_cases)

          # Convert error to expected format
          all_errors << {
            code: error_info[:code],
            name: error_info[:name],
            qualified_name: error_info[:qualified_name],
            documentation: error_info[:documentation],
            file: error_info[:file],
            cases: converted_cases
          }
        end

        # Export JSON
        UI.message "📄 Generating JSON documentation..."
        json_output = {
          summary: {
            total_files: summary[:total_files],
            total_enums: summary[:total_enums],
            total_cases: summary[:total_cases],
            generated_at: Time.now.iso8601
          },
          errors: all_errors.map do |error|
            {
              code: error[:code],
              name: error[:name],
              qualified_name: error[:qualified_name],
              documentation: error[:documentation],
              file: error[:file].sub(sources_dir + '/', ''),
              cases: error[:cases].map do |case_info|
                {
                  code: case_info[:error_code],
                  full_id: case_info[:full_id],
                  name: case_info[:name],
                  qualified_name: case_info[:qualified_case_name],
                  documentation: case_info[:documentation]
                }
              end
            }
          end
        }

        json_file = File.join(output_dir, 'errors.json')
        File.write(json_file, JSON.pretty_generate(json_output))
        UI.success "   ✅ JSON: #{json_file}"

        # Export DOT graph
        UI.message "🔗 Generating DOT graph..."
        dot_file = File.join(output_dir, 'errors.dot')
        File.open(dot_file, 'w') do |f|
          f.puts 'digraph G {'
          f.puts '  rankdir=LR;'
          f.puts '  ranksep="0.2 equally";'
          f.puts '  node [shape=plaintext];'
          f.puts '  stylesheet="error_graph.css";'
          f.puts

          all_errors.each do |error|
            # Generate table rows for cases
            case_rows = ""
            
            if error[:cases].empty?
              case_rows = "<TR>\n    <TD SIDES=\"TLB\" ALIGN=\"RIGHT\"><FONT COLOR=\"GRAY\" POINT-SIZE=\"8\">i-</FONT></TD>\n    <TD SIDES=\"TRB\" ALIGN=\"LEFT\" WIDTH=\"200\" PORT=\"NoCases\" HREF=\"#\" TOOLTIP=\"\"><FONT POINT-SIZE=\"10\">No cases defined</FONT></TD>\n</TR>"
            else
              error[:cases].each do |case_info|
                case_port = GenerateErrorDocumentationAction.escape_dot_id(case_info[:name])
                case_display = GenerateErrorDocumentationAction.escape_html(case_info[:name])
                case_id = "i-#{case_info[:full_id]}"
                case_rows += "<TR>\n    <TD SIDES=\"TLB\" ALIGN=\"RIGHT\"><FONT COLOR=\"GRAY\" POINT-SIZE=\"8\">#{case_id}</FONT></TD>\n    <TD SIDES=\"TRB\" ALIGN=\"LEFT\" WIDTH=\"200\" PORT=\"#{case_port}\" HREF=\"#\" TOOLTIP=\"\"><FONT POINT-SIZE=\"10\">#{case_display}</FONT></TD>\n</TR>\n"
              end
            end
            
            # Generate node with old-style HTML table
            display_name = GenerateErrorDocumentationAction.get_display_name(error)
            f.puts "    \"#{GenerateErrorDocumentationAction.escape_html(display_name)}\" ["
            f.puts "        label="
            f.puts "    <"
            f.puts "<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\">"
            f.puts "  <TR>"
            f.puts "    <TD BGCOLOR=\"lightgray\" PORT=\"#{GenerateErrorDocumentationAction.escape_html(display_name)}\" width=\"200\" COLSPAN=\"2\" ID=\"#{GenerateErrorDocumentationAction.escape_html(display_name)}\"><FONT POINT-SIZE=\"16.0\">#{GenerateErrorDocumentationAction.escape_html(display_name)}</FONT></TD>"
            f.puts "  </TR>"
            f.puts case_rows.chomp
            f.puts "</TABLE>"
            f.puts ">"
            f.puts "        id=\"#{GenerateErrorDocumentationAction.escape_html(display_name)}\""
            f.puts "        fontsize=\"10pt\""
            f.puts "        href=\"errors.html##{error[:name].downcase}\""
            f.puts "    ];"
            f.puts
          end

          # Add edges for related errors
          all_errors.each do |error|
            error[:cases].each do |case_info|
              next unless case_info[:assoc_types]
              
              case_info[:assoc_types].each do |assoc_type|
                if is_error_type?(assoc_type)
                  # Find the target enum
                  target_error = all_errors.find { |e| e[:qualified_name] == assoc_type || e[:name] == assoc_type }
                  if target_error
                    source_display_name = GenerateErrorDocumentationAction.get_display_name(error)
                    target_display_name = GenerateErrorDocumentationAction.get_display_name(target_error)
                    source_node = "\"#{GenerateErrorDocumentationAction.escape_html(source_display_name)}\""
                    target_node = "\"#{GenerateErrorDocumentationAction.escape_html(target_display_name)}\""
                    
                    # Use the escaped case name as the port for DOT syntax
                    case_port = GenerateErrorDocumentationAction.escape_dot_id(case_info[:name])
                    
                    f.puts "  #{source_node}:#{case_port} -> #{target_node};"
                  end
                end
              end
            end
          end

          f.puts '}'
        end
        UI.success "   ✅ DOT: #{dot_file}"

        # Generate SVG from DOT
        svg_file = File.join(output_dir, 'error_graph.svg')
        if system("command -v dot > /dev/null 2>&1")
          if system("dot -Tsvg '#{dot_file}' -o '#{svg_file}' 2>/dev/null")
            UI.success "   ✅ SVG: #{svg_file}"
          else
            UI.message "   ⚠️  Could not generate SVG (dot command failed)"
          end
        else
          UI.message "   ⚠️  Could not generate SVG (graphviz not installed)"
        end

        # Generate Markdown documentation for AI agents
        UI.message "📝 Generating Markdown documentation for AI agents..."
        markdown_file = File.join(output_dir, 'errors.md')
        generate_markdown_documentation(markdown_file, all_errors, summary)
        UI.success "   ✅ Markdown: #{markdown_file}"

        # Generate individual error HTML viewer
        UI.message "🌐 Generating individual error HTML viewer..."
        error_details_file = File.join(output_dir, 'error_details.html')
        generate_error_details_html(error_details_file, all_errors, summary)
        UI.success "   ✅ Error Details HTML: #{error_details_file}"

        # Copy HTML search interface
        output_html_file = html_file = File.join(output_dir, 'error_search.html')
        copy_html_search_interface(output_html_file)
        UI.success("✅ Error search interface copied to #{output_html_file}")

        # Copy shared CSS file
        output_css_file = File.join(output_dir, 'shared_styles.css')
        copy_shared_css(output_css_file)
        UI.success("✅ Shared CSS copied to #{output_css_file}")

        UI.success "🎉 Documentation generated successfully!"
        UI.message "📁 Output directory: #{output_dir}"

        # Return summary for use in other actions
        {
          total_files: summary[:total_files],
          total_enums: summary[:total_enums],
          total_cases: summary[:total_cases],
          output_dir: output_dir
        }
      end

      def self.generate_markdown_documentation(output_file, all_errors, summary)
        template_path = File.join(Dir.pwd, 'Templates', 'ERB', 'errors.md.erb')
        
        unless File.exist?(template_path)
          UI.error("❌ Template not found: #{template_path}")
          return
        end
        
        template_content = File.read(template_path)
        erb = ERB.new(template_content, trim_mode: '-')
        
        result = erb.result(binding)
        File.write(output_file, result)
      end

      def self.generate_error_details_html(output_file, all_errors, summary)
        template_path = File.join(Dir.pwd, 'Templates', 'ERB', 'error_details.html.erb')
        
        unless File.exist?(template_path)
          UI.error("❌ Template not found: #{template_path}")
          return
        end
        
        template_content = File.read(template_path)
        erb = ERB.new(template_content, trim_mode: '-')
        
        result = erb.result(binding)
        File.write(output_file, result)
      end

      def self.escape_html(str)
        str.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;').gsub("'", '&#39;')
      end

      def self.escape_dot_id(str)
        # For DOT identifiers, remove backticks completely to avoid syntax errors
        str.to_s.gsub('`', '').gsub(/[^a-zA-Z0-9_]/, '_')
      end

      def self.get_display_name(error)
        # If the enum name is generic like "Error", use a more meaningful name
        if error[:name] == "Error" && error[:qualified_name] && error[:qualified_name] != "Error"
          # Extract a better name from the qualified name
          parts = error[:qualified_name].split('.')
          if parts.length > 1
            # Use the parent class/struct name + Error
            parent = parts[-2]
            return "#{parent}Error"
          end
        end
        error[:name]
      end

      def self.is_error_type?(type_name)
        return false if type_name.nil? || type_name.empty?
        # More comprehensive check for error types
        type_name.end_with?('Error') || 
        type_name == 'Swift.Error' || 
        type_name == 'NSError' ||
        type_name == 'Error'
      end

      def self.copy_html_search_interface(output_path)
        # Look for the HTML file in the project root first, then in Templates
        project_root = File.expand_path('..', Dir.pwd) # Go up from fastlane directory
        
        possible_sources = [
        #   File.join(project_root, 'error_search.html'),
        #   File.join(project_root, 'Templates', 'error_search.html'),
        #   File.join(Dir.pwd, 'error_search.html'),
          File.join(Dir.pwd, 'Templates', 'error_search.html')
        ]
        
        source_file = possible_sources.find { |path| File.exist?(path) }
        
        if source_file
          FileUtils.cp(source_file, output_path)
          UI.message("📋 Copied error search interface from #{source_file}")
        else
          UI.error("❌ Could not find error_search.html in any of these locations:")
          possible_sources.each { |path| UI.error("   - #{path}") }
          UI.error("Please ensure the file exists in one of these locations.")
        end
      end

      def self.copy_shared_css(output_path)
        # Look for the shared CSS file in Templates/ERB directory
        project_root = File.expand_path('..', Dir.pwd) # Go up from fastlane directory
        
        possible_sources = [
          File.join(Dir.pwd, 'Templates', 'ERB', 'shared_styles.css')
        ]
        
        source_file = possible_sources.find { |path| File.exist?(path) }
        
        if source_file
          FileUtils.cp(source_file, output_path)
          UI.message("🎨 Copied shared CSS from #{source_file}")
        else
          UI.error("❌ Could not find shared_styles.css in any of these locations:")
          possible_sources.each { |path| UI.error("   - #{path}") }
          UI.error("Please ensure the file exists in one of these locations.")
        end
      end

      def self.description
        "Generate comprehensive error documentation from Swift @CodedError and @ErrorCode macros"
      end

      def self.details
        "This action parses Swift source files for @CodedError enums and @ErrorCode cases, " \
        "generating comprehensive documentation including JSON data, DOT graphs, SVG visualizations, " \
        "and an interactive HTML search interface."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :sources_dir,
            env_name: "ERROR_DOC_SOURCES_DIR",
            description: "Directory containing Swift source files",
            type: String,
            default_value: "Sources"
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_dir,
            env_name: "ERROR_DOC_OUTPUT_DIR", 
            description: "Directory for generated documentation",
            type: String,
            default_value: "docs/errors"
          )
        ]
      end

      def self.return_value
        "Hash containing summary statistics and output directory path"
      end

      def self.authors
        ["GitHub Copilot"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end