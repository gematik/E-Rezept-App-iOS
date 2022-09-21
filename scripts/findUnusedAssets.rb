#!/usr/bin/env ruby

def testElements(input)
  orphanedElements = []

  for element in input do
    hasMatch = false

    Dir.glob("sources/eRpApp/**/*.swift").each do |file|
      next if file.include?("Generated")
      open(file).each_line do |line|
        for value in element[:values] do
          hasMatch = true if line.include?(value)
          break if hasMatch
        end
        break if hasMatch
      end

      break if hasMatch
    end

    puts "'#{element[:name]}' seems orphaned" unless hasMatch
    orphanedElements.append(element[:name]) unless hasMatch
  end

  orphanedElements
end

require 'yaml'

class String
  def capitalize_first
    return self if self.length == 0

    letters = self.split('')
    letters.first.upcase!
    letters.join
  end
end

def transformSnailCase(input)
  input.gsub("\%@", "").split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize_first) }.join
end

def mapNames(path, input)
  input.reduce([]) { |result, value|
    camelCased = transformSnailCase(value)
    result + [
      {
        :name => value,
        :values => [
          (["A11y"] + path + [camelCased]).join("."),
          (["A18n"] + path + [camelCased]).join("."),
        ]
      }
    ]
  }
end

def transform(path, input)
  case input.class.to_s
  when "Array"
    return mapNames(path, input)
  when "Hash"
    return input
    .map { |k,v|
      transform(path + [k], v)
    }
    .reduce([]) { |result, value|
      result + value
    }
  end
end

def removeL10nElements(elements)
  l10nfiles = [
    "./Sources/eRpApp/Resources/en-GB.lproj/Localizable.strings",
    "./Sources/eRpApp/Resources/de.lproj/Localizable.strings",
    "./Sources/eRpApp/Resources/tr.lproj/Localizable.strings"
  ]

  for file in l10nfiles do
    removeL10nElementsFromFile(elements.clone, file)
  end
end

def removeL10nElementsFromFile(elements, file)
  while currentElement = elements.shift do
    input_lines = File.readlines(file)

    File.open(file, 'w') do |out_file|
      for line in input_lines do
        if !currentElement || !line.include?("\"#{currentElement}\" = ")
          out_file.puts line
        else
          currentElement = elements.shift
        end
      end
    end
  end
end

def removeA11yElements(elements)
  file = "./Sources/eRpApp/Resources/AccessibilityIdentifier.yaml"

  input_lines = File.readlines(file)

  elements = elements.clone

  currentElement = elements.shift

  File.open(file, 'w') do |out_file|
    for line in input_lines do
      if !currentElement || !line.include?("#{currentElement}\n")
        out_file.puts line
      else
        currentElement = elements.shift
      end
    end
  end
end

puts "\nFind unused LOCALIZATION keys:\n\n"

localizationInputFile = File.open("./Sources/eRpApp/Resources/en-GB.lproj/Localizable.strings")
localizationInput = localizationInputFile.readlines.map { |line|
  line.split(" = ").first.gsub("\"", "")
}
.map { |element|
  {
    :name => element,
    :values => [
      "L10n.#{transformSnailCase(element)}",
      "\"#{element}\"",
    ]
  }
}

l10nElements = testElements(localizationInput)
removeL10nElements(l10nElements)

puts "\nFind unused ACCESSIBILITY identifier:\n\n"

accessibilityInputFile = YAML.load_file("./Sources/eRpApp/Resources/AccessibilityIdentifier.yaml")
accessibilityInput = transform([], accessibilityInputFile)

a11yElements = testElements(accessibilityInput)
removeA11yElements(a11yElements)
