#include "dehash_phone.hpp"

int main() {
    string phones_knowed_path = "", phones_hashed_path = "";
    
    ifstream config("config.cfg");
    string line;
    while(getline(config, line)) {
        string key, value;
        bool key_is_reading = true;
        for (const auto& sym : line) {
            if (sym != '=' && sym != '\n') {
                if (key_is_reading)
                    key.append(string(1, sym));
                else
                    value.append(string(1, sym));
            } else {
                key_is_reading = false;
            }
        }
        if (key == "phones") phones_knowed_path = value;
        else if (key == "hashes") phones_hashed_path = value;
        else if (key == "hashcat") hashcat_path = value;
        else if (key == "potfile") pot_path = value;
        else if (key == "dehashes") dehash_salted_path = value;
    }
    
    if (phones_knowed_path == "") {
        cout << "Enter the phones knowed path: "; cin >> phones_knowed_path;
    }
    if (phones_hashed_path == "") {
        cout << "Enter the phones hashes path: "; cin >> phones_hashed_path;
    }
    if (hashcat_path == "") {
        cout << "Enter the hashcat path: "; cin >> hashcat_path;
    }
    if (pot_path == "") {
        cout << "Enter the potfile path: "; cin >> pot_path;
    }
    if (dehash_salted_path == "") {
        cout << "Enter the dehashes path: "; cin >> dehash_salted_path;
    }
    
    DehashPhone *dehashphone = new DehashPhone("", "", "", true);
    dehashphone->remove_potfile();
    dehashphone->restart("/Users/maus/phones-knowed.txt", "/Users/maus/hash-salt-phones.txt", "MD5");
    dehashphone->find_possible_salts();
    dehashphone->dehash_with_salt();
}


