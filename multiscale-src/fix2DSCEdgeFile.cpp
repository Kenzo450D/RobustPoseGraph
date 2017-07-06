#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

using namespace std;

int main(int argc, char* argv[])
{
    if (argc !=2 )
    {
        cout << "Error In Input Parameters\n";
        cout << "Needs one Parameter:\n";
        cout << "Param1: <g2o edge file(.txt file)>\n";
        return -1;
    }
    string   fileName = argv[1];
    ifstream inFile;

    //---- read input file
    inFile.open(fileName.c_str());

    //---- generate output file name
    size_t idx         = fileName.find_last_of(".");
    string filewoE     = fileName.substr(0,idx); //fileName without extension
    string outFileName = filewoE + "Fixed.txt";

    //---- Test Print the fileNames
//    cout << "Output Vertex File: " << outVertices << endl;
//    cout << "Output Edge File  : " << outEdges << endl;

    //---- generate output file stream
    ofstream eFileStream;
    eFileStream.open(outFileName.c_str());

    //---- read the file 
    string   line;
    char delim = ' ';
    int lineCount = 1;
    if (inFile.is_open())
    {
        while(getline(inFile, line))
        {
            vector <string> elems;
            stringstream ss(line);
            string item;
            int flag = 0;
            while ( getline(ss,item,delim))
            {
                elems.push_back(item);
            }
            if (elems.size() != 11)
            {
                for (vector<string>::size_type i = 1; i != elems.size(); i++) 
                {
                    eFileStream << elems[i] << " ";
                }
                eFileStream << endl;
            }
            else
            {
                eFileStream << line << endl;
            }
        }
    }
    else
    {
        cout << "Unable to open file\n";
        return -1;
    }
    //---- Close file streams
    inFile.close();
    eFileStream.close();
    return 0;
}
