import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import '../utils/file_utils.dart';
import 'config_exception.dart';

/// Handles parsing Yaml config file
/// If file is specified arguments are parsed from it
/// Otherwise it tries to access 'swagger_parser.yaml'
/// which is a default name for config file
/// If 'swagger_parser.yaml' doesn't exist and
/// file is not specified in arguments,
/// attempts to get config from pubspec.yaml
/// If that fails, throws an exception
class YamlConfig {
  YamlConfig(List<String> arguments) {
    final parser = ArgParser()..addOption('file', abbr: 'f');
    final configFile = getConfigFile(
      filePath: parser.parse(arguments)['file']?.toString(),
    );
    if (configFile == null) {
      throw const ConfigException("Can't find yaml config file.");
    }

    final yamlFileContent = configFile.readAsStringSync();
    final dynamic yamlFile = loadYaml(yamlFileContent);

    if (yamlFile is! YamlMap) {
      throw ConfigException(
        "Failed to extract config from the 'pubspec.yaml' file.\n"
        'Expected YAML map but got ${yamlFile.runtimeType}.',
      );
    }

    final yamlConfig = yamlFile['swagger_parser'] as YamlMap?;
    if (yamlConfig == null) {
      throw ConfigException(
        "`${configFile.path}` file does not contain a 'swagger_parser' section.",
      );
    }
    if (yamlConfig.containsKey('schema_path')) {
      _schemaFilePath = yamlConfig['schema_path'].toString();
    }
    if (_schemaFilePath == null) {
      throw const ConfigException(
        "Config parameter 'schema_path' is required.",
      );
    }

    if (yamlConfig.containsKey('output_directory')) {
      _outputDirectory = yamlConfig['output_directory'].toString();
    }
    if (_outputDirectory == null) {
      throw const ConfigException(
        "Config parameter 'output_directory' is required.",
      );
    }

    if (yamlConfig.containsKey('language')) {
      _language = yamlConfig['language'].toString();
    }

    if (yamlConfig.containsKey('root_interface')) {
      if (yamlConfig['root_interface'] is! bool?) {
        throw const ConfigException(
          "Config parameter 'root_interface' must be bool.",
        );
      }
      _rootInterface = yamlConfig['root_interface'] as bool?;
    }

    if (yamlConfig.containsKey('client_postfix')) {
      final postfix = yamlConfig['client_postfix']?.toString();
      _clientPostfix =
          postfix == null || postfix.trim().isEmpty ? null : postfix;
    }

    if (yamlConfig.containsKey('squish_clients')) {
      if (yamlConfig['squish_clients'] is! bool?) {
        throw const ConfigException(
          "Config parameter 'squish_clients' must be bool.",
        );
      }
      _squishClients = yamlConfig['squish_clients'] as bool?;
    }

    if (yamlConfig.containsKey('freezed')) {
      if (yamlConfig['freezed'] is! bool?) {
        throw const ConfigException("Config parameter 'freezed' must be bool.");
      }
      _freezed = yamlConfig['freezed'] as bool?;
    }
  }

  String? _outputDirectory;
  String? _schemaFilePath;
  String? _language;
  String? _clientPostfix;
  bool? _rootInterface;
  bool? _squishClients;
  bool? _freezed;

  String get outputDirectory => _outputDirectory!;

  String get schemaFilePath => _schemaFilePath!;

  String? get language => _language;

  String? get clientPostfix => _clientPostfix;

  bool? get rootInterface => _rootInterface;

  bool? get squishClients => _squishClients;

  bool? get freezed => _freezed;
}
