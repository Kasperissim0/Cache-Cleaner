# Cache Cleaner

A simple script to clean user and system cache on macOS.

## How to use

1.  Clone the repository.
2.  Run the script:
    ```bash
    ./cache_cleaner.sh
    ```
3.  The script will list the cache files and ask for confirmation before deleting them.
4.  The output of the script is logged in the `logs` directory.

## Logs

-   `logs/cache_cleaner.log`: General log messages.
-   `logs/cache_cleaner_out.log`: Output of the `ls` and `rm` commands.
-   `logs/cache_cleaner_err.log`: Errors from the `ls` and `rm` commands.