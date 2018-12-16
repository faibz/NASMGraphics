#include "types.h"
#include "user.h"
#include "fs.h"

bool fullDetailsFlagPresent(char** argv, int argc);
bool recursiveFlagPresent(char** argv, int argc);
int getSpecifiedDirectoryIndex(char** argv, int argc);
int printFileNameAndExtension(struct _DirectoryEntry* directoryEntry);
void processDirectoryEntry(int directoryDescriptor, bool fullDetails, bool recursive);
int readFileAttributes(int attributes, char* buffer);
int readFileDate(int date, int column);
int readFileTime(int time, int column);

char* fileAttributes[8] = { "Read Only", "Hidden", "System", "VolumeLabel", "Subdirectory", "Archive", "Device", "Unused" };

int main(int argc, char *argv[])
{
	if (argc > 4)
	{
		return -1;
	}

	int specifiedDirectoryIndex = getSpecifiedDirectoryIndex(argv, argc);
	int directoryDescriptor = specifiedDirectoryIndex == -1 ? opendir(" ") : opendir(argv[specifiedDirectoryIndex]);
	
	if (directoryDescriptor == 0)
	{
		exit();
	}

	processDirectoryEntry(directoryDescriptor, fullDetailsFlagPresent(argv, argc), recursiveFlagPresent(argv, argc));

	if (closedir(directoryDescriptor) < 0)
	{
		exit();
	}

	exit();

	return 0;
}

bool fullDetailsFlagPresent(char** argv, int argc)
{
	for(int i = 1; i < argc; ++i)
	{
		if (argv[i][0] == '-' && argv[i][1] == 'l') 
		{
			return true;
		}
	}

	return false;
}

bool recursiveFlagPresent(char** argv, int argc)
{
	for(int i = 1; i < argc; ++i)
	{
		if (argv[i][0] == '-' && argv[i][1] == 'R') 
		{
			return true;
		}
	}

	return false;
}

int getSpecifiedDirectoryIndex(char** argv, int argc)
{
	for(int i = 1; i < argc; ++i)
	{
		if (argv[i][0] != '-') return i;
	}

	return -1;
}

int printFileNameAndExtension(struct _DirectoryEntry* directoryEntry)
{
	char fileName[9] = {0};
	char fileExtension[4] = {0};
	char fileNameAndExtension[13] = {0};

	for (int i = 0; i < 8; ++i)
	{
		if (directoryEntry->Filename[i] == ' ')
		{
			break;
		}

		fileName[i] = directoryEntry->Filename[i];
	}

	fileName[8] = 0;

	for (int i = 0; i < 3; ++i)
	{
		if (directoryEntry->Ext[i] == ' ')
		{
			break;
		}

		fileExtension[i] = directoryEntry->Ext[i];
	}

	fileExtension[3] = 0;

	memmove(fileNameAndExtension, fileName, strlen(fileName));

	if (fileExtension[0] != 0) 
	{
		fileNameAndExtension[strlen(fileName)] = '.';
	}

	memmove(fileNameAndExtension + strlen(fileName) + 1, fileExtension, strlen(fileExtension));
	fileNameAndExtension[strlen(fileNameAndExtension)] = 0;
	printf("%s ", fileNameAndExtension);

	return 0;
}

void processDirectoryEntry(int directoryDescriptor, bool fullDetails, bool recursive)
{
	struct _DirectoryEntry* directoryEntry = malloc(32);

	while (readdir(directoryDescriptor, directoryEntry) >= 0)
	{
		printFileNameAndExtension(directoryEntry);

		if (fullDetails)
		{
			char attributeBuffer[100] = {0};
			readFileAttributes(directoryEntry->Attrib, attributeBuffer);

			printf("(Created on: %d/%d/%d at %d:%d:%d.%d. Last modified on: %d/%d/%d at %d:%d:%d. Size: %d. Attributes: %s \n", 
				readFileDate(directoryEntry->DateCreated, 0), readFileDate(directoryEntry->DateCreated, 1), 
				readFileDate(directoryEntry->DateCreated, 2), readFileTime(directoryEntry->TimeCreated, 2), 
				readFileTime(directoryEntry->TimeCreated, 1), readFileTime(directoryEntry->TimeCreated, 0),
				directoryEntry->TimeCreatedMs, 
				readFileDate(directoryEntry->LastModDate, 0), readFileDate(directoryEntry->LastModDate, 1), 
				readFileDate(directoryEntry->LastModDate, 2), readFileTime(directoryEntry->LastModTime, 2), 
				readFileTime(directoryEntry->LastModTime, 1), readFileTime(directoryEntry->LastModTime, 0),
				directoryEntry->FileSize, attributeBuffer);
		}
		else
		{
			printf("\n");
		}
		
		if (recursive && directoryEntry->FileSize == 0 && directoryEntry->Filename[0] != '.')
		{
			char fileName[9] = {0};
			memmove(fileName, directoryEntry->Filename, 8);
			fileName[strlen(fileName)] = 0;

			int recDirDesc = opendir(fileName);
			processDirectoryEntry(recDirDesc, fullDetails, true);
		}
	}
}

int readFileAttributes(int attributes, char* buffer)
{
	for(int i = 0; i < 8; ++i)
	{
		int bitActive = (attributes >> i) & 1;
		if (bitActive == 1) 
		{
			memmove(buffer + strlen(buffer), fileAttributes[i], strlen(fileAttributes[i]));
			buffer[strlen(buffer)] = ',';
		}
	} 

	if (strlen(buffer) > 0) 
	{
		buffer[strlen(buffer) - 1] = '.';
	}

	return 0;
}

int readFileDate(int date, int column)
{
	//2 bytes - bits 0-4: day (1-31) | bits 5-8: month (1-12) | bits 9-15: year from 1980 (21 -> 2001)

	int bitsToExtract = 0;
	int position = 1;

	if (column == 0) //days
	{
		bitsToExtract = 5;
	}
	else if (column == 1) //month
	{
		bitsToExtract = 4;
		position = 6;
	}
	else if (column == 2) //year
	{
		bitsToExtract = 7;
		position = 10;
	}

	int value = (((1 << bitsToExtract) - 1) & (date >> (position - 1)));

	return column == 2 ?  1980 + value : value;
}

int readFileTime(int time, int column)
{
	//2 bytes - bits 0-4: seconds (0-29 [2 second accuracy so 29 -> 58]) | bits 5-10: minutes (0-59) | bits 11-15: hours (0-23)

	int bitsToExtract = 0;
	int position = 1;

	if (column == 0) //seconds
	{
		bitsToExtract = 5;
	}
	else if (column == 1) //minutes
	{
		bitsToExtract = 6;
		position = 6;
		
	}
	else if (column == 2) //hours
	{
		bitsToExtract = 5;
		position = 12;
	}

	int value = (((1 << bitsToExtract) - 1) & (time >> (position - 1)));

	return column == 0 ? value * 2 : value;
}