#include <iostream>
#include <string>

using namespace std;

int main(int argc, char* argv[])
{
    if (argc !=3 )
    {
        cout << "Error In Input Parameters\n";
        cout << "Needs two Parameter:\n";
        cout << "Param1: <Total Chi2 Error>\n";
        cout << "Param2: <Number of edges>\n";
        return -1;
    }
    string chi2str = argv[1];
    string nEdgesStr  = argv[2];
    double chi2Total = std::stod(chi2str);
    double nEdges    = std::stod(nEdgesStr);
    double ans       = chi2Total / nEdges;
    cout << ans << endl;
    return 1;
}