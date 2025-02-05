#!/bin/bash

# 引入global error handler
source ./error_handle.sh

custom_err_log="./shell.err"

# 執行第一個錯誤指令, 錯誤輸出至stderr
wrongcommand1

#執行第2個錯誤指令, 將stderr重定向至./shell.err
wrongcommand2 2>$custom_err_log

#執行第3個錯誤指令, 錯誤輸出至stderr
wrongcommand3

# 因為錯誤訊息已經重定向至./shell.err, 所以不會再輸出至stderr，必須手動將合併至stderr
append_error $custom_err_log