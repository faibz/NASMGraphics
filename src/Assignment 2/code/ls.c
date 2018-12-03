#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "x86.h"
#include "defs.h"
#include "mmu.h"
#include "param.h"
#include "memlayout.h"
//#include "proc.h"

// #include "file.h"

int main(int argc, char *argv[])
{
	int i;

	printf("Argument count: %d\n", argc);

	if (argc > 2)
	{
		return -1;
	}

	for (i = 1; i < argc; i++)
	{
		printf("%s%s", argv[i], i + 1 < argc ? " " : "\n");
	}

	

	// if (argc == 2)
	// {
	// 	process_specified_directory(argv[1]);
	// }
	// else 
	// {
	// 	process_current_directory();
	// }

	// int directoryDescriptor = opendir(argv[1]);

	// if (directoryDescriptor == 0)
	// {
	// 	exit();
	// }

	// struct _DirectoryEntry* directoryEntry;
	// if (readdir(directoryDescriptor, directoryEntry) < 0) //error or end of directory reached
	// {
	// 	exit();
	// }

	// if (closedir(directoryDescriptor) < 0)
	// {
	// 	exit();
	// }

	exit();
}

int process_specified_directory(char* directory)
{
	return -1;
}

// int cpuId() 
// {
// 	return myCpu() - cpus;
// }

// Cpu* myCpu(void)
// {
// 	int apicid, i;

// 	if (readExtendedFlags() & FL_IF)
// 	{
// 		panic("myCpu called with interrupts enabled\n");
// 	}
// 	apicid = localApicId();
// 	// APIC IDs are not guaranteed to be contiguous. Maybe we should have
// 	// a reverse map, or reserve a register to store &cpus[i].
// 	for (i = 0; i < ncpu; ++i) 
// 	{
// 		if (cpus[i].Apicid == apicid)
// 		{
// 			return &cpus[i];
// 		}
// 	}
// 	panic("unknown apicid\n");
// }

// // Disable interrupts so that we are not rescheduled
// // while reading Process from the cpu structure

// Process* myProcess(void) 
// {
// 	Cpu *c;
// 	Process *p;

// 	pushCli();
// 	c = myCpu();
// 	p = c->Process;
// 	popCli();
// 	return p;
// }