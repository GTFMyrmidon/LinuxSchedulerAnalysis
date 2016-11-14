/*
* File: rw.c
* Author: Andy Sayler
* Revised: Shivakant Mishra, Vincent Mahathirash
* Project: CSCI 3753 Programming Assignment 4
* Create Date: 2012/30/10
* Modify Date: 2016/30/10
* Modify Date: 2016/13/11
* Description: A small i/o bound program to copy N bytes from an input
*              file to an output file. May read the input file multiple
*              times if N is larger than the size of the input file.
* Usage: ./rw [TRANSFERSIZE] [BLOCKSIZE] [INPUT] [OUTPUT] [POLICY] [PROCESSES]
* [PRIORITY]
*/

/* Include Flags */
#define _GNU_SOURCE

/* System Includes */
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <stdbool.h>
#include <time.h>

/* Local Defines */
#define MAXFILENAMELENGTH 80
#define DEFAULT_INPUTFILENAME "rwinput"
#define DEFAULT_OUTPUTFILENAMEBASE "rwoutput"
#define DEFAULT_BLOCKSIZE 1024
#define DEFAULT_TRANSFERSIZE 1024*100

int main(int argc, char* argv[])
{
    int rv;
    int inputFD;
    int outputFD;
    char inputFilename[MAXFILENAMELENGTH];
    char outputFilename[MAXFILENAMELENGTH];
    char outputFilenameBase[MAXFILENAMELENGTH];

    ssize_t transfersize = 0;
    ssize_t blocksize = 0;
    char* transferBuffer = NULL;
    ssize_t buffersize;

    ssize_t bytesRead = 0;
    ssize_t totalBytesRead = 0;
    int totalReads = 0;
    ssize_t bytesWritten = 0;
    ssize_t totalBytesWritten = 0;
    int totalWrites = 0;
    int inputFileResets = 0;

    long i;
    long numProcesses;
    pid_t pid;
    struct sched_param param;
    int policy;
    bool samePriority;

    /* Process program arguments to select run-time parameters */
    /* Set supplied transfer size or default if not supplied */
    if (argc < 2)
    {
        transfersize = DEFAULT_TRANSFERSIZE;
    }

    else
    {
        transfersize = atol(argv[1]);
        if (transfersize < 1){
            fprintf(stderr, "Bad transfersize value\n");
            return EXIT_FAILURE;
        }
    }

    /* Set supplied block size or default if not supplied */
    if (argc < 3)
    {
        blocksize = DEFAULT_BLOCKSIZE;
    }

    else
    {
        blocksize = atol(argv[2]);
        if (blocksize < 1){
            fprintf(stderr, "Bad blocksize value\n");
            return EXIT_FAILURE;
        }
    }

    /* Set supplied input filename or default if not supplied */
    if (argc < 4)
    {
        if (strnlen(DEFAULT_INPUTFILENAME, MAXFILENAMELENGTH) >= MAXFILENAMELENGTH)
        {
            fprintf(stderr, "Default input filename too long\n");
            return EXIT_FAILURE;
        }
        strncpy(inputFilename, DEFAULT_INPUTFILENAME, MAXFILENAMELENGTH);
    }

    else
    {
        if (strnlen(argv[3], MAXFILENAMELENGTH) >= MAXFILENAMELENGTH)
        {
            fprintf(stderr, "Input filename too long\n");
            return EXIT_FAILURE;
        }
        strncpy(inputFilename, argv[3], MAXFILENAMELENGTH);
    }

    /* Set supplied output filename base or default if not supplied */
    if (argc < 5)
    {
        if (strnlen(DEFAULT_OUTPUTFILENAMEBASE, MAXFILENAMELENGTH) >= MAXFILENAMELENGTH)
        {
            fprintf(stderr, "Default output filename base too long\n");
            return EXIT_FAILURE;
        }
        strncpy(outputFilenameBase, DEFAULT_OUTPUTFILENAMEBASE, MAXFILENAMELENGTH);
    }

    else
    {
        if (strnlen(argv[4], MAXFILENAMELENGTH) >= MAXFILENAMELENGTH)
        {
            fprintf(stderr, "Output filename base is too long\n");
            return EXIT_FAILURE;
        }
        strncpy(outputFilenameBase, argv[4], MAXFILENAMELENGTH);
    }

    // Set default policy if not supplied
    if (argc < 6)
    {
        policy = SCHED_OTHER;
    }

    else
    {
        if (!strcmp(argv[5], "SCHED_OTHER"))
        {
            policy = SCHED_OTHER;
        }
        else if (!strcmp(argv[5], "SCHED_FIFO"))
        {
            policy = SCHED_FIFO;
        }
        else if (!strcmp(argv[5], "SCHED_RR"))
        {
            policy = SCHED_RR;
        }
        else
        {
            fprintf(stderr, "Unhandeled scheduling policy\n");
            return EXIT_FAILURE;
        }
    }

    // Set default number of processes if not supplied
    if (argc < 7)
    {
        numProcesses = 10;
    }

    else
    {
        numProcesses = atol(argv[6]);
    }

    // Set default priority/nice value flag if not supplied
    if (argc < 8)
    {
        samePriority = true;
    }

    else
    {
        samePriority = atoi(argv[7]);
    }

    /* Confirm blocksize is multiple of and less than transfersize*/
    if (blocksize > transfersize)
    {
        fprintf(stderr, "blocksize can not exceed transfersize\n");
        return EXIT_FAILURE;
    }

    if (transfersize % blocksize)
    {
        fprintf(stderr, "blocksize must be multiple of transfersize\n");
        return EXIT_FAILURE;
    }

    if (samePriority)
    {
        param.sched_priority = sched_get_priority_max(policy);

        fprintf(stdout, "Current Scheduling Policy: %d\n", sched_getscheduler(0));
        fprintf(stdout, "Setting Scheduling Policy to: %d\n", policy);
        if (sched_setscheduler(0, policy, &param))
        {
            perror("Error setting scheduler policy");
            return EXIT_FAILURE;
        }
        fprintf(stdout, "New Scheduling Policy: %d\n", sched_getscheduler(0));

        for (i = 0; i < numProcesses; ++i)
        {
            pid = fork();
            if (pid == 0)
            {
                break;
            }
        }
    }

    else // Differing priorities/nice values
    {
        if (policy != SCHED_OTHER) // Set different priorites per process
        {
            int min = sched_get_priority_min(policy);
            int max = sched_get_priority_max(policy);
            for (i = 0; i < numProcesses; ++i)
            {
                // Set process to random priority in [min, max] for given scheduler
                param.sched_priority = min + rand() / (RAND_MAX / (max - min + 1) + 1);
                printf("Priority: %d\n", param.sched_priority);

                // Set new scheduler policy

                // DEBUG
                fprintf(stdout, "Current Scheduling Policy: %d\n", sched_getscheduler(0));
                fprintf(stdout, "Setting Scheduling Policy to: %d\n", policy);

                if (sched_setscheduler(0, policy, &param))
                {
                    perror("Error setting scheduler policy");
                    return EXIT_FAILURE;
                }

                // DEBUG
                fprintf(stdout, "New Scheduling Policy: %d\n", sched_getscheduler(0));

                pid = fork();
                if (pid == 0)
                {
                    break;
                }
            }
        }

        else // Priority = 0, set different nice values per process
        {
            int min = -20;
            int max = 19;
            for (i = 0; i < numProcesses; ++i)
            {
                // Set process to max priority for given scheduler
                param.sched_priority = sched_get_priority_max(policy);

                // Set new scheduler policy
                fprintf(stdout, "Current Scheduling Policy: %d\n", sched_getscheduler(0));
                fprintf(stdout, "Setting Scheduling Policy to: %d\n", policy);
                if (sched_setscheduler(0, policy, &param))
                {
                    perror("Error setting scheduler policy");
                    return EXIT_FAILURE;
                }
                fprintf(stdout, "New Scheduling Policy: %d\n", sched_getscheduler(0));

                // Calculate new nice value
                int currNVal = getpriority(PRIO_PROCESS, 0);
                printf("Current Nice Value: %d\n", currNVal);

                // Set nice value of process to random value in [min, max]
                int niceVal = min + rand() / (RAND_MAX / (max - min + 1) + 1);
                printf("Target Value: %d\n", niceVal);
                setpriority(PRIO_PROCESS, 0, niceVal);
                currNVal = getpriority(PRIO_PROCESS, 0);

                // DEBUG
                printf("New Nice Value: %d\n", currNVal);

                pid = fork();
                if (pid == 0)
                {
                    break;
                }
            }
        }
    }

    // Children: Read from input deposit to output
    if (pid == 0)
    {
        /* Allocate buffer space */
        buffersize = blocksize;
        if (!(transferBuffer = malloc(buffersize*sizeof(*transferBuffer))))
        {
            perror("Failed to allocate transfer buffer");
            return EXIT_FAILURE;
        }

        /* Open Input File Descriptor in Read Only mode */
        if ((inputFD = open(inputFilename, O_RDONLY | O_SYNC)) < 0)
        {
            perror("Failed to open input file");
            return EXIT_FAILURE;
        }

        /* Open Output File Descriptor in Write Only mode with standard permissions*/
        rv = snprintf(outputFilename, MAXFILENAMELENGTH, "%s-%d",
        outputFilenameBase, getpid());
        if (rv > MAXFILENAMELENGTH)
        {
            fprintf(stderr, "Output filenmae length exceeds limit of %d characters.\n",
            MAXFILENAMELENGTH);
            return EXIT_FAILURE;
        }
        else if (rv < 0)
        {
            perror("Failed to generate output filename");
            return EXIT_FAILURE;
        }
        if ((outputFD = open(outputFilename, O_WRONLY | O_CREAT | O_TRUNC | O_SYNC,
            S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH)) < 0)
            {
                perror("Failed to open output file");
                return EXIT_FAILURE;
            }

            /* Print Status */
            fprintf(stdout, "Reading from %s and writing to %s\n",
            inputFilename, outputFilename);

            /* Read from input file and write to output file*/
            do
            {
                /* Read transfersize bytes from input file*/
                bytesRead = read(inputFD, transferBuffer, buffersize);
                if (bytesRead < 0)
                {
                    perror("Error reading input file");
                    return EXIT_FAILURE;
                }
                else
                {
                    totalBytesRead += bytesRead;
                    totalReads++;
                }

                /* If all bytes were read, write to output file*/
                if (bytesRead == blocksize)
                {
                    bytesWritten = write(outputFD, transferBuffer, bytesRead);
                    if (bytesWritten < 0)
                    {
                        perror("Error writing output file");
                        return EXIT_FAILURE;
                    }
                    else
                    {
                        totalBytesWritten += bytesWritten;
                        totalWrites++;
                    }
                }
                /* Otherwise assume we have reached the end of the input file and reset */
                else
                {
                    if (lseek(inputFD, 0, SEEK_SET))
                    {
                        perror("Error resetting to beginning of file");
                        return EXIT_FAILURE;
                    }
                    inputFileResets++;
                }
            }
            while(totalBytesWritten < transfersize);

            /* Output some possibly helpfull info to make it seem like we were doing stuff */
            fprintf(stdout, "Read:    %zd bytes in %d reads\n",
            totalBytesRead, totalReads);
            fprintf(stdout, "Written: %zd bytes in %d writes\n",
            totalBytesWritten, totalWrites);
            fprintf(stdout, "Read input file in %d pass%s\n",
            (inputFileResets + 1), (inputFileResets ? "es" : ""));
            fprintf(stdout, "Processed %zd bytes in blocks of %zd bytes\n",
            transfersize, blocksize);

            /* Free Buffer */
            free(transferBuffer);

            /* Close Output File Descriptor */
            if (close(outputFD))
            {
                perror("Failed to close output file");
                return EXIT_FAILURE;
            }

            /* Close Input File Descriptor */
            if (close(inputFD))
            {
                perror("Failed to close input file");
                return EXIT_FAILURE;
            }
        }

        // Parent: Wait for children
        while(wait(NULL) > 0);

        return EXIT_SUCCESS;
    }
