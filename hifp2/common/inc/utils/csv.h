#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

typedef struct
{
    vector<string> header;
    vector<vector<string> > rows;
} csv_data;

int parse_csv_from_matrix(
    int num_of_collumns, 
    int num_of_rows, 
    int *matrix, 
    csv_data *csv
);
int write_csv_file(
    csv_data *data, 
    string filename
);