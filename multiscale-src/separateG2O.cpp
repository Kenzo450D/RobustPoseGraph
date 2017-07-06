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
        cout << "Param1: <g2o file>\n";
        return -1;
    }
    string   fileName = argv[1];
    ifstream inFile;

    //---- read input file
    inFile.open(fileName.c_str());

    //---- generate output file name
    size_t idx         = fileName.find_last_of(".");
    string filewoE     = fileName.substr(0,idx); //fileName without extension
    string outVertices = filewoE + "Vertices.txt";
    string outEdges    = filewoE + "Edges.txt";

    //---- Test Print the fileNames
//    cout << "Output Vertex File: " << outVertices << endl;
//    cout << "Output Edge File  : " << outEdges << endl;

    //---- generate output file stream
    ofstream vFileStream;
    ofstream eFileStream;
    vFileStream.open(outVertices.c_str());
    eFileStream.open(outEdges.c_str());

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
            if (elems[0] == "VERTEX_SE2" || elems[0] == "VERTEX_SE3:QUAT")
            {
                //---- put line in vertex file
                for( vector<string>::size_type i = 1; i != elems.size(); i++)
                {
                    vFileStream << elems[i] << " ";
                }
                vFileStream << endl;
            }
            else if (elems[0] == "EDGE_SE2" || elems[0] == "EDGE_SE3:QUAT" || elems[0] == "EDGE_SE2_MAXMIX")
            {
                //cout << "First element: " << elems[0] << "\n";
                //---- put line in edge file
                for( vector<string>::size_type i = 1; i != elems.size(); i++)
                {
                    eFileStream << elems[i] << " ";
                    //cout << elems[i] << " ";
                }
                eFileStream << endl;
                //cout << endl;
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
    vFileStream.close();
    return 0;
}
