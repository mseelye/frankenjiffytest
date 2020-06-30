/*
 *  FrankenJiffyTest - Used to test Rogue JiffyDOS kernals
 *  (C) 2020 - Mark Seelye / mseelye@yahoo.com
 *  Version 0.1
 *
 *  Requires: cc65 dev environment, build essentials (make)
 *  Optional: 
 *     tmpx for assembling the basic bootstrap.
 *     Vice tooling for c1541
 *
 *  build with:
 *    make clean all
 *
 *  Run with:
 *    Your Commodore 64! (Or VICE)
 *
 *  Notes:
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version
 *  2 of the License, or (at your option) any later version.
 */

#include <stdio.h>
#include <stdlib.h>

typedef struct {
    unsigned short eightShorts[8];
} Line;

int quickChecksum(unsigned short nums[8]) {
    int i, checkSum = 0;
    
    for(i = 0; i < 7; i++) {
        checkSum += nums[i];
    }
    if(nums[7]!=checkSum) {
        printf("\nchecksum failure! was %d expected %d\n", checkSum, nums[7]);
    }
    return checkSum;
}


void ScanFile (FILE* f) {
    int numLines;
    int lineNum;
    Line *Lines;
    Line *line;

    if(fscanf(f,"%d", &numLines)!= 1)
        printf("Invalid Header: numLines:%d", numLines);
    Lines = (Line *)malloc(sizeof(Line)*(numLines+1));
    if(Lines==NULL) {
        printf("malloc(%d) failed: ", sizeof(Line));
        printf("Out of memory");
        exit(1);
    }

    line=Lines;

    for(lineNum=0; lineNum < numLines; lineNum++, line++) {
        if(fscanf(f,"%hd %hd %hd %hd %hd %hd %hd %hd",
            &line->eightShorts[0],
            &line->eightShorts[1],
            &line->eightShorts[2],
            &line->eightShorts[3],
            &line->eightShorts[4],
            &line->eightShorts[5],
            &line->eightShorts[6],
            &line->eightShorts[7])!=8) {

            printf("Bad line %d - %d %d %d %d %d %d %d %d\n",lineNum,
                line->eightShorts[0],
                line->eightShorts[1],
                line->eightShorts[2],
                line->eightShorts[3],
                line->eightShorts[4],
                line->eightShorts[5],
                line->eightShorts[6],
                line->eightShorts[7]);
            exit(1);
        }
        printf("#%d-%d %d %d %d %d %d %d %d-c:%d\n",lineNum,
            line->eightShorts[0],
            line->eightShorts[1],
            line->eightShorts[2],
            line->eightShorts[3],
            line->eightShorts[4],
            line->eightShorts[5],
            line->eightShorts[6],
            line->eightShorts[7], quickChecksum(line->eightShorts));
    }
}

int main(int argc, char *argv[])
{
    FILE *f;
    char *fn;

    if(argc<2) {
        fn = "testfile1";
    } else {
        fn = argv[1];
    }

    f=fopen(fn,"r");
    if(f==NULL)
    {
        perror(argv[1]);
        exit(1);
    }

    ScanFile(f);
    fclose(f);

    printf("done!");
}
