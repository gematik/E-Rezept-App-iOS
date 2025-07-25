//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Foundation
import PackagePlugin

@main
struct ErpAppPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        let developmentEnv = target.directory.appending("development.env")
        let developmentApiKeysEnv = target.directory.appending("development.apikeys.env")
        let developmentStaticEnv = target.directory.appending("development.static.env")
        let developmentEnvDefault = target.directory.appending("development.env.default")
        let outputEnvironment = context.pluginWorkDirectory.appending("EnvironmentParser.swift")
        let generatorToolSecrets = try context.tool(named: "EnvironmentParser").path

        return [
            createExampleBuildCommand(
                developmentEnv: developmentEnv,
                developmentApiKeysEnv: developmentApiKeysEnv,
                developmentStaticEnv: developmentStaticEnv,
                developmentEnvDefault: developmentEnvDefault,
                in: outputEnvironment,
                with: generatorToolSecrets
            ),
        ]
    }
}

extension ErpAppPlugin {
    // swiftlint:disable:next function_parameter_count
    func createExampleBuildCommand(
        developmentEnv: Path,
        developmentApiKeysEnv: Path,
        developmentStaticEnv: Path,
        developmentEnvDefault: Path,
        in outputDirectoryPath: Path,
        with generatorToolPath: Path
    ) -> Command {
        .buildCommand(
            displayName: "Generate environment code",
            executable: generatorToolPath,
            arguments: [
                developmentEnv,
                developmentApiKeysEnv,
                developmentStaticEnv,
                developmentEnvDefault,
                outputDirectoryPath,
            ],
            environment: [:],
            inputFiles: [developmentEnv, developmentApiKeysEnv, developmentStaticEnv, developmentEnvDefault],
            outputFiles: [outputDirectoryPath]
        )
    }
}
