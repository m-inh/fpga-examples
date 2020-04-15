#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>

#include "hifp/hifp.h"

using namespace hifp;

const char *IDIR = "../distorted-wav";
const char *ODIR = "./distorted-fp";

/* Entry point */
int main(int argc, char **argv)
{
    DIR *dir = NULL;
    struct dirent *ep;
    char ifpath[256];
    char ofpath[256];
    FILE *ifp = NULL;
    FILE *ofp = NULL;
    int r;

    dir = opendir(IDIR);

    ASSERT(dir != NULL);

    while ((ep = readdir(dir)) != NULL)
    {
        if (ep->d_type == DT_REG)
        {
            sprintf(ifpath, "%s/%s", IDIR, ep->d_name);
            sprintf(ofpath, "%s/%s.raw", ODIR, ep->d_name);

            ifp = fopen(ifpath, "rb+");
            ASSERT(ifp != NULL);

            ofp = fopen(ofpath, "wb");
            ASSERT(ifp != NULL);

            r = run_all(ifp, ofp);
            ASSERT(r == 0);

            fclose(ifp);
            ifp = NULL;

            fclose(ofp);
            ofp = NULL;
        }
    }

    closedir(dir);

    return 0;

err:
    if (ifp != NULL)
    {
        fclose(ifp);
    }
    if (ofp != NULL)
    {
        fclose(ofp);
    }
    if (dir != NULL)
    {
        closedir(dir);
    }
    return 0;
}
