 /**
 * Create a file with one edge each, take the chi2 error based on that edge, and
 * then report the chi2 error in the output file.
 * Author: sayantan <dot> knz <at> gmail <dot> com
 */
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

using namespace std;

float getChi2Error(string fileName)
{
    string tmpChi2ErrorFile = "tmpChi2ErrorFile.txt";
    string command = "./getErrorForG2Ofile.sh "+fileName +" "+tmpChi2ErrorFile;
    system(command.c_str());
    ifstream inFile;
    inFile.open(tmpChi2ErrorFile);
    float chi2Error=0;
    string line;
    if (inFile.is_open())
    {
        while(getline(inFile, line))
        {
            chi2Error = stof(line);
        }
    }
    else
    {
        cerr << "Could not read the temporary chi2 error file\n";
    }
    remove(tmpChi2ErrorFile.c_str());
    return chi2Error;
}

int main(int argc, char* argv[])
{
    if (argc !=3 )
    {
        cout << "Error In Input Parameters\n";
        cout << "Needs two Parameters:\n";
        cout << "Param1: <input g2o file>\n";
        cout << "Param2: <output chi2 error file>\n";
        return -1;
    }
    string   fileName = argv[1];
    string   outFile  = argv[2];
    ifstream inFile;
    string tmpFile="20160311temporaryG2oFile.g2o";
    //---- read input file
    inFile.open(fileName.c_str());

    //---- generate output file stream
    ofstream out;
    out.open(outFile.c_str());

    //---- generate output file stream for vertices file
    size_t idx         = fileName.find_last_of(".");
    string filewoE     = fileName.substr(0,idx); //fileName without extension
    string outVertices = filewoE + "Vertices.txt";
    string outEdges    = filewoE + "Edges.txt";
    ofstream vFileStream; // to store vertices and odometry edges
    ofstream loopClosureEdgeFileStream; // to store loop closure Edges
    vFileStream.open(outVertices.c_str());
    loopClosureEdgeFileStream.open(outEdges.c_str());

    //---- Create a vertices file;
    //---- read the file
    string   line;
    char delim = ' ';
    int loopClosureEdgeCount = 0;
    bool switched = true;
    int v1,v2;
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
            if (elems[0] == "VERTEX_SE2")
            {
                vFileStream << line << endl;
            }
            if (elems[0] == "EDGE_SE2")
            {
                v1 = stoi(elems[1]);
                v2 = stoi(elems[2]);
                if ((v2 - v1) == 1)
                {
                    // odometry edge
                    vFileStream << line << endl;
                }
                else
                {
                    loopClosureEdgeCount = loopClosureEdgeCount + 1;
                    loopClosureEdgeFileStream << line << endl;
                }
            }
        }
    }
    else
    {
        cerr << "Unable to open file\n";
        return -1;
    }
    //---- Close file streams
    inFile.close();
    loopClosureEdgeFileStream.close();
    vFileStream.close();

    //---- Copy the vertices file to a new file, add a single edge, and check
    //     chi2 error
    // -- Step1: Read the edges file
    ifstream inEdgeStream;
    inEdgeStream.open(outEdges.c_str());
    float chi2error;
    int edgesEncountered = 0;
    float currentStatus = 0;
    float benchStatus = 0.1;
    if (inEdgeStream.is_open())
    {
        while(getline(inEdgeStream, line))
        {
            // -- Step2: Copy the vertices and odometry edge
            ifstream inVertexStream;
            inVertexStream.open(outVertices.c_str());
            ofstream outVertexStream(tmpFile.c_str());
            outVertexStream << inVertexStream.rdbuf();
            inVertexStream.close();
            // -- Step 3. Print the edge in the output File Stream
            outVertexStream << line;
            outVertexStream.close();
            inVertexStream.close();
            // -- Step 4. Calculate the chi2 error
            chi2error = getChi2Error(tmpFile);
            out << chi2error  << "\n";
            // -- Debug: report status of algorithm
            edgesEncountered = edgesEncountered + 1;
            currentStatus = (float)edgesEncountered / (float)loopClosureEdgeCount;
            if (currentStatus >= benchStatus)
            {
            	cout << benchStatus << " Completed!" << endl;
            	benchStatus = benchStatus + 0.1;
            }
        }
    }
    else
    {
        cerr << "Unable to open Edge file\n";
        return -1;
    }
    out.close();
    inEdgeStream.close();
    // --- Clean up: Remove the files which were created for compute
    remove(outVertices.c_str());
    remove(outEdges.c_str());
    remove(tmpFile.c_str());
    return 0;
}