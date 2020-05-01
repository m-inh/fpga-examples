#include "utils/csv.h"

int add_collumn(
    csv_data *csv,
    string collumn_name,
    vector<double> collumn_data
)
{
    vector<string> stringify_data;
    for (int i=0; i<collumn_data.size(); i++) {
        stringify_data.push_back(to_string(collumn_data[i]));
    }

    return add_collumn(csv, collumn_name, stringify_data);
}

int add_collumn(
    csv_data *csv,
    string collumn_name,
    vector<string> collumn_data
)
{
    csv->header.push_back(collumn_name);
    csv->rows.push_back(collumn_data);

    return 1;
}

int parse_csv_from_matrix(
    int num_of_collumns, 
    int num_of_rows, 
    int *matrix, 
    csv_data *csv
)
{
    vector<vector<string> > rows;

    for (int i=0; i<num_of_collumns; i++) {
        vector<string> r;
        for (int j=0; j<num_of_rows; j++) {
            int v = *((matrix + i*num_of_rows) + j);
            printf("%d ", v);
            r.push_back(to_string(v));
        }
        rows.push_back(r);
    }

    csv->rows = rows;

    return 1;
}


int write_csv_file_h(
    csv_data *data, 
    string filename
)
{
    ofstream output_file;

    // create and open the .csv file
    output_file.open(filename, ios::out | ios::trunc);

    // write the file headers
    for (int i = 0; i < data->header.size(); i++)
    {
        output_file << data->header[i];

        if (i < data->header.size() - 1)
        {
            output_file << ",";
        }
    }
    output_file << endl;

    // write data to the file
    for (int i = 0; i < data->rows.size(); i++)
    {
        for (int j=0; j < data->rows[i].size(); j++) {
            output_file << data->rows[i][j];

            if (j < data->rows[i].size() - 1) {
                output_file << ",";
            }
        }
        output_file << endl;
    }

    // close the output file
    output_file.close();

    return 1;
}

int write_csv_file_v(
    csv_data *data, 
    string filename
)
{
    ofstream output_file;

    // create and open the .csv file
    output_file.open(filename, ios::out | ios::trunc);

    // write the file headers
    for (int i = 0; i < data->header.size(); i++)
    {
        output_file << data->header[i];

        if (i < data->header.size() - 1)
        {
            output_file << ",";
        }
    }
    output_file << endl;

    // write data to the file
    for (int i = 0; i < data->rows[0].size(); i++)
    {
        for (int j=0; j < data->header.size(); j++) {
            output_file << data->rows[j][i];

            if (j < data->header.size() - 1) {
                output_file << ",";
            }
        }
        output_file << endl;
    }

    // close the output file
    output_file.close();

    return 1;
}