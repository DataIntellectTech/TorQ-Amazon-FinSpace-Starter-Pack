Setup QPad
===============

You must follow these steps from within your EC2 instance.

## Download QPad

Navigate to the [qInsightPad](https://www.qinsightpad.com/) website and select the download arrow.

![Download button on qpad website](workshop/graphics/qpad_download1.png)

Download the relavent version (usually x64).

![Download x64 version](workshop/graphics/qpad_download2.png)

Download the [Microsoft C++ 2010 service pack](https://www.microsoft.com/en-gb/download/details.aspx?id=26999) (there is a specific DLL from this that you need that is usually installed on Windows machines).

![Download MSPack](workshop/graphics/MSpack_download.png)

Select the relavent version (usually x64).

![Download MSPack select version](workshop/graphics/MSpack_download2.png)

Run the file that was just downloaded.

Search for ‘Edit Environment variables’ and add ``SSL_VERIFY_SERVER=NO`` as one of them.

![Edit Environment Variables 1](workshop/graphics/edit_env_var1.png)
![Edit Environment Variables 2](workshop/graphics/edit_env_var2.png)
![Edit Environment Variables 3](workshop/graphics/edit_env_var3.png)