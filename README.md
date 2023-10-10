<img height="150px" width="150px" src="icone.jpg"></img>
# Hive Shell Documentation 


Hive Shell is a specialized auxiliary development tool tailored for Flutter developers who leverage Hive as their local data storage solution. The tool provides an intuitive command-line interface, enabling developers to interact in real-time with their Hive boxes without the need for additional scripts, enhancing their development flow.

## Main Features:

- **Simplified Command-Line Interface:** With straightforward and intuitive commands, developers can quickly inspect, modify, or analyze the data stored in their Hive boxes.

- **Agile Development:** Eradicates the need for separate scripts to inspect or modify boxes, delivering a faster and more efficient development cycle.

- **Developer-Centric:** Designed with Flutter app developers in mind, Hive Shell is attuned to the specific challenges and needs faced when working with Hive, streamlining the entire process.

## Usage:

While Hive Shell provides a streamlined interface, it assumes that developers have familiarity with their data structures and the names of the boxes they wish to interact with. This knowledge empowers developers to swiftly access and modify their Hive boxes, simplifying the development and debugging processes.

## Commands:

### General:

- **`--version` or `-v`:** Displays the version of Hive Shell.

```sh
hshell --version
```

- **`--help` or `-h`:** Displays the available commands and their descriptions.

```sh
hshell --help
```

### Hive Box Interaction:

1. **Add Data**:
    - **Usage**: 
        ```sh
        hshell --path=<path_to_hive_file> add --key=<key_name> --value=<value>
        ```

2. **Update Data**:
    - **Usage**:
        ```sh
        hshell --path=<path_to_hive_file> update --key=<key_name> --value=<new_value>
        ```

3. **Delete Data**:
    - **Usage**:
        ```sh
        hshell --path=<path_to_hive_file> delete --key=<key_name>
        ```

4. **List Data**:
    - **Usage**:
        ```sh
        hshell --path=<path_to_hive_file> datas
        ```

5. **Backup Hive Box**:
    - **Usage**:
        ```sh
        hshell --path=<path_to_hive_file> backup --destination=<backup_location>
        ```

6. **Restore from Backup**:
    - **Usage**:
        ```sh
        hshell --path=<path_to_hive_file> restore --source=<backup_file_location>
        ```

## Specifics:

- The tool uses `adb` (Android Debug Bridge) to interact with devices. Therefore, ensure you have `adb` installed and accessible from your command line.

- Restoring from a backup currently replaces the original box file entirely. Future implementations may allow for a merge approach, where developers can determine how data should merge in the case of conflicts between the backup and the original data.

- While working with the tool, make sure you are providing the correct box path, especially when using operations that modify data, to prevent unintended data loss.

## Conclusion:
Hive Shell is a powerful utility for developers working with Hive in their Flutter applications. By integrating this tool into their workflow, developers can ensure a smoother and more efficient development process.
