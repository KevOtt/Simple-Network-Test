# Simple Network Test


## About

This is a small script utility originally created to automate testing of firewall rules and dns resolution of numerous similar remote sites. Running the script will test the response of specified TCP ports for each IP and attempt a name resolution from the local DNS provided. These items are defined in a config file for repeated usage.

Mostly this is useful if you have a number of systems for which you want to test the same network communication, such as in the case of infrastructure services (AD, puppet, etc.)

## Download
The tool is provided as a standalone .exe file in a .zip archive.

|Release|Link                |
|-------|--------------------|
|v1.1   |[Simple-NetworkTest-v1.1][Simple-NetworkTest-v1.1]|

[Simple-NetworkTest-v1.1]: https://github.com/KevOtt/Simple-Network-Test/releases/download/v1.1/Simple.Network.Test.zip

## How to Use
Edit the included config file to include the IPs, ports, and names being tested.  Specify one destination per line, in the order "description; device FQDN; destination IP; TCP ports". Separate fields by ";" and separate multiple ports separated by "," on the same line. Comment lines are specified with leading "#"

The script will use by default any file named "SimpleNetworkTest_Config.txt" left in the same directory, otherwise alternate can be specified at run with the "-ConfigFile" option.

### Example

>Webserver; Server1.example.com; 10.0.0.1; 80,443
>Fileserver; FileServer.example.com; 10.0.0.120; 445

## Screenshots

Example utility output:
<p align="center">
  <img src="/Docs/Screenshots/SampleOutput.png" width="900" title="Screenshot">
</p>

Example config file:
<p align="center">
  <img src="/Docs/Screenshots/SampleConfigFile.png" width="700" title="Screenshot">
</p>

## License

Win Info is licensed under the [MIT license][].

[MIT license]: https://github.com/KevOtt/Simple-Network-Test/blob/master/LICENSE