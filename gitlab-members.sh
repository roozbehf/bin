#!/bin/bash
#
# Given a Gitlab group id and assuming that 
# the gitlab cli is set up to access GitLab API, 
# it fetches the list of all members in the group and its 
# subgroups and projects. 
#
# Copyright (c) 2019, Roozbeh Farahbod
#

SCRIPT_NAME=`basename $0`
ROOT_GROUP_ID="$1"

if [ -z "${ROOT_GROUP_ID}" ] 
then
    echo "ERROR: Group ID is missing."
    echo "Usage: ${SCRIPT_NAME} <group-id>"
    exit 1
fi

GITLAB_CLI=gitlab

OUTPUT_DIR=gitlab-members

FILE_ALL_GROUPS=${OUTPUT_DIR}/all-groups
FILE_GROUP_MEMBERS=${OUTPUT_DIR}/group-members
FILE_GROUP_PROJECTS=${OUTPUT_DIR}/group-projects
FILE_PROJECT_MEMBERS=${OUTPUT_DIR}/project-members
FILE_ALL_MEMBERS_TEMP=${OUTPUT_DIR}/all-members.temp
FILE_ALL_MEMBERS=${OUTPUT_DIR}/all-members

mkdir -p ${OUTPUT_DIR}

echo -n "Deleting result files... "
rm -f ${FILE_ALL_GROUPS} ${FILE_GROUP_MEMBERS} ${FILE_GROUP_PROJECTS} ${FILE_PROJECT_MEMBERS} ${FILE_ALL_MEMBERS_TEMP} ${FILE_ALL_MEMBERS}
echo "done."

echo -n "Fetching all groups... "
echo "id: ${ROOT_GROUP_ID}" > ${FILE_ALL_GROUPS}
${GITLAB_CLI} group-subgroup list --group-id ${ROOT_GROUP_ID} >> ${FILE_ALL_GROUPS}
echo "done."

echo -n "Fetching group projects... "
cat ${FILE_ALL_GROUPS} | grep ":" | sed 's/.*: //g' | while read gi ; do echo "group: $gi"; ${GITLAB_CLI} group-project list --group-id $gi; done > ${FILE_GROUP_PROJECTS}
echo "done."

echo -n "Fetching group members... "
cat ${FILE_ALL_GROUPS} | grep ":" | sed 's/.*: //g' | while read gi ; do echo "group: $gi"; ${GITLAB_CLI} group-member list --group-id $gi; done > ${FILE_GROUP_MEMBERS} 
echo "done."

echo -n "Fetching project members... "
cat ${FILE_GROUP_PROJECTS} | grep "id:" | sed 's/^id: //g' | while read pi; do echo "project: $pi"; ${GITLAB_CLI} project-member list --project-id $pi; done > ${FILE_PROJECT_MEMBERS}
echo "done."

echo -n "Combining the results... "
cat ${FILE_GROUP_MEMBERS} | grep "username:" | sed 's/^username: //g' > ${FILE_ALL_MEMBERS_TEMP}
cat ${FILE_PROJECT_MEMBERS} | grep "username:" | sed 's/^username: //g' >> ${FILE_ALL_MEMBERS_TEMP}
cat ${FILE_ALL_MEMBERS_TEMP} | sort | uniq > ${FILE_ALL_MEMBERS}
rm -f ${FILE_ALL_MEMBERS_TEMP}
echo "done."

