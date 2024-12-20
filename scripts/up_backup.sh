#!/bin/bash

# 來源和目標目錄設定
SOURCE_DIR="/UploadApFile/ApFile/Data/DGS"
BACKUP_DIR="/offline/DGS"
DATE_SUFFIX=$(date +%Y%m%d_%H%M%S)

# 要排除的目錄和檔案類型
EXCLUDE_DIRS=".git node_modules tmp cache"
EXCLUDE_FILES="*.log *.tmp *.bak $(basename "$0")"

# 建立排除參數字串
EXCLUDE_PARAMS=""
for dir in $EXCLUDE_DIRS; do
    EXCLUDE_PARAMS="$EXCLUDE_PARAMS -not -path '*/$dir/*'"
done
for pattern in $EXCLUDE_FILES; do
    EXCLUDE_PARAMS="$EXCLUDE_PARAMS -not -name '$pattern'"
done

# 計算預計備份的檔案數量
precheck_backup() {
    echo "正在計算預計備份的檔案數量..."
    EXPECTED_COUNT=$(eval "find '$SOURCE_DIR' -type f $EXCLUDE_PARAMS" | wc -l)
    echo "預計備份檔案數量: $EXPECTED_COUNT"
}

# 建立備份目錄並執行備份
create_backup() {
    BACKUP_PATH="${BACKUP_DIR}/backup_${DATE_SUFFIX}"
    mkdir -p "$BACKUP_PATH"

    echo "開始執行備份..."
    #eval "find '$SOURCE_DIR' -type f $EXCLUDE_PARAMS -exec rsync -R {} '$BACKUP_PATH' \;"
    eval "find '$SOURCE_DIR' -type f $EXCLUDE_PARAMS -exec cp --parents {} '$BACKUP_PATH' \;"
}

# 驗證備份內容
varify_backup(){
  # 驗證備份後的檔案數量
  ACTUAL_COUNT=$(find "$BACKUP_PATH" -type f | wc -l)
  echo "實際備份檔案數量: $ACTUAL_COUNT"

  # 比對檔案數量
  if [ "$EXPECTED_COUNT" -eq "$ACTUAL_COUNT" ]; then
      echo "備份完成，檔案數量符合預期"
  else
      echo "警告：檔案數量不符合預期"
      echo "預期數量: $EXPECTED_COUNT"
      echo "實際數量: $ACTUAL_COUNT"
      exit 1
  fi

  # 產生備份報告
  echo "產生備份報告..."
  {
      echo "備份時間: $(date)"
      echo "來源目錄: $SOURCE_DIR"
      echo "備份目錄: $BACKUP_PATH"
      echo "排除目錄: $EXCLUDE_DIRS"
      echo "排除檔案類型: $EXCLUDE_FILES"
      echo "預期檔案數量: $EXPECTED_COUNT"
      echo "實際檔案數量: $ACTUAL_COUNT"
  } >> "$BACKUP_PATH/backup_report.txt"

  echo "計算檔案大小及MD5..."
  {
      echo "檔案大小及MD5檢查:"
      find "$SOURCE_DIR" -type f $EXCLUDE_PARAMS -exec sh -c 'echo "$(stat -c%s "$1") $(md5sum "$1" | awk "{print \$1}") $1"' _ {} \; | while read -r size md5 file; do
  #        backup_file="$BACKUP_PATH${file#$SOURCE_DIR}"
          backup_file="$BACKUP_PATH${file}"
          if [ -f "$backup_file" ]; then
              backup_size=$(stat -c%s "$backup_file")
              backup_md5=$(md5sum "$backup_file" | awk '{print $1}')
              if [ "$size" -eq "$backup_size" ] && [ "$md5" == "$backup_md5" ]; then
                  echo "SIZE and MD5 MATCHED: $backup_file"
              else
                  echo "SIZE or MD5 DIFFERENT: $backup_file"
              fi
          else
              echo "MISSING FILE: $backup_file"
          fi
      done
  } >> "$BACKUP_PATH/backup_report.txt"
}

precheck_backup
# 確認是否繼續
read -p "是否繼續備份? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi
create_backup
varify_backup

chmod -R 755 "$BACKUP_PATH"

echo "備份作業完成"