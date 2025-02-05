# Shell Exception Handle

- 程式開始執行會建立global error file
- 程式執行過程若針對standard error重定向，則需手動合併至global error file
- 程式結束時，若global error file不為空，則會自動處理 (call sp、api轉入db ......)

## Usage

- 在程式中載入[error_handle.sh](error_handle.sh)
``` shell
    #!/bin/bash

    source ./error_handle.sh
```
- 若程式中將standard errer重定向至檔案，透過呼叫append_error將錯誤合併至global error file

``` shell
    append_error ${your_custom_error_file}
```
其他請參考[sample_shell.sh](sample_shell.sh)