#!/usr/bin/env bash




# DAMP 目錄
SCRIPT=$(readlink -f $0)
TOP_DIR=$(dirname $(dirname $(dirname $SCRIPT)))


# 讀取設定檔
source "${TOP_DIR}/.env"


# 檢查 project group 是否已存在
GREP_GROUP=$(grep "^${PROJECT_GROUP}" /etc/group)
if [ $? -eq 0 ]; then

	# 檢查 project group GID 是否正確
	CHECK_GID=$(echo "${GREP_GROUP}" | grep ":${PROJECT_GID}:")
	if [ $? -ne 0 ]; then
		echo -e "System project group exists but GID is incorrect.\n"
		exit 1
	fi

else

	# 建立 project group (加上 --system 為創建系統群組)
	groupadd --system --gid ${PROJECT_GID} ${PROJECT_GROUP}
	if [ $? -ne 0 ]; then
		echo -e "Create system project group (${PROJECT_GROUP}) failed.\n"
		exit 1
	else
		echo -e "Create system project group (${PROJECT_GROUP}) succeeded.\n"
	fi

fi


# 檢查 project user 是否已存在
USER_UID=$(id -u ${PROJECT_USER} 2> /dev/null)
if [ $? -eq 0 ]; then

	# 檢查 project user UID 是否正確
	USER_GID=$(id -g ${PROJECT_USER})
	if [ ${USER_UID} -ne ${PROJECT_UID} ]; then
		echo -e "System project user exists but UID is incorrect. (UID: ${USER_UID}, project UID: ${PROJECT_UID})\n"
		exit 1
	fi

	# 檢查 project user's group 是否屬於 project group
	GREP_GROUPS=$(id -Gn ${PROJECT_USER} | grep "\b${PROJECT_GROUP}\b")
	if [ $? -ne 0 ]; then
		echo -e "System project user is not belong system project group. (${PROJECT_GROUP})\n"
		exit 1
	fi

	echo -e "System project user (${PROJECT_USER}) already exists.\n"
	exit 0

fi


# 建立 project user (加上 --system 為創建系統帳號，不會產生家目錄，不可登錄)
adduser --system --uid ${PROJECT_UID} --groups ${PROJECT_GROUP} ${PROJECT_USER}
if [ $? -eq 0 ]; then
	echo -e "Create system project user (${PROJECT_USER}) succeeded.\n"
	id ${PROJECT_USER}
fi
