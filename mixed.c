/*
* File: pi-sched.c
* Author: Andy Sayler
* Revised: Dhivakant Mishra, Vincent Mahathirash
* Project: CSCI 3753 Programming Assignment 4
* Create Date: 2012/03/07
* Modify Date: 2012/03/09
* Modify Date: 2016/31/10
* Modify Date: 2016/13/11
* Description:
* 	This file contains a simple program for statistically
*   calculating pi using a specific scheduling policy.
* Usage: ./pi-sched [ITERATIONS] [POLICY] [PROCESSES] [PRIORITY]
*/

/* Local Includes */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include <sched.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <stdbool.h>
#include <time.h>

#define DEFAULT_ITERATIONS 1000000
#define RADIUS (RAND_MAX / 2)
#define __alwaysInline __attribute__((always_inline))

static inline double __alwaysInline dist(double x0, double y0, double x1, double y1)
{
    return sqrt(pow((x1 - x0), 2) + pow((y1 - y0), 2));
}

static inline double __alwaysInline zeroDist(double x, double y)
{
    return dist(0, 0, x, y);
}

int main(int argc, char* argv[])
{
    long i;
    long iterations;
    struct sched_param param;
    int policy;
    double x, y;
    double inCircle = 0.0;
    double inSquare = 0.0;
    double pCircle = 0.0;
    double piCalc = 0.0;

    pid_t pid;
    long numProcesses;
    bool samePriority;

    FILE *outFP;

    srand(time(NULL));

    // Process program arguments to select iterations and policy

    // Set default iterations if not supplied
    if (argc < 2)
    {
        iterations = DEFAULT_ITERATIONS;
    }

    // Set default policy if not supplied
    if (argc < 3)
    {
        policy = SCHED_OTHER;
    }

    // Set default number of proccesses if not supplied
    if (argc < 4)
    {
        numProcesses = 10;
    }

    if (argc < 5)
    {
        samePriority = true;
    }

    // Set iterations if supplied
    if (argc > 1)
    {
        iterations = atol(argv[1]);
        if (iterations < 1)
        {
            fprintf(stderr, "Bad iterations value\n");
            return EXIT_FAILURE;
        }
    }

    // Set policy if supplied
    if (argc > 2)
    {
        if (!strcmp(argv[2], "SCHED_OTHER"))
        {
            policy = SCHED_OTHER;
        }

        else if (!strcmp(argv[2], "SCHED_FIFO"))
        {
            policy = SCHED_FIFO;
        }
        else if (!strcmp(argv[2], "SCHED_RR"))
        {
            policy = SCHED_RR;
        }
        else
        {
            fprintf(stderr, "Unhandeled scheduling policy\n");
            return EXIT_FAILURE;
        }
    }

    // Set number of processes if supplied
    if (argc > 3)
    {
        if (numProcesses < 1)
        {
            fprintf(stderr, "Bad processes value\n");
            return EXIT_FAILURE;
        }
        else
        numProcesses = atol(argv[3]);
    }

    // Set priority/nice value flag is supplied
    if (argc > 4)
    {
        samePriority = atoi(argv[4]);
    }

    if (samePriority)
    {
        // Set process to max priority for given scheduler
        param.sched_priority = sched_get_priority_max(policy);

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
        if (policy != SCHED_OTHER) // Set different priorities per process
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
        else // Priority = 0, set different nice value per process
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

    // Children: Calculate pi using statistical method across all iterations
    if (pid == 0)
    {
        outFP = fopen("/dev/null", "w");
        for (i = 0; i<iterations; ++i)
        {
            x = (random() % (RADIUS * 2)) - RADIUS;
            y = (random() % (RADIUS * 2)) - RADIUS;
            if (zeroDist(x,y) < RADIUS)
            {
                inCircle++;
                fprintf(outFP, "%f\n", inCircle);
            }
            inSquare++;
            fprintf(outFP, "%f\n", inSquare);
        }

        // Finish calculation
        pCircle = inCircle/inSquare;
        piCalc = pCircle * 4.0;

        // Print result
        fprintf(stdout, "pi = %f\n", piCalc);

        fclose(outFP);
    }

    // Parent: Wait for children
    while (wait(NULL) > 0);

    return EXIT_SUCCESS;
}
