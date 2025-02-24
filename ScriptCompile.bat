REM Divine Logic (c) 2019, Sjshovan (LoTekkie) 
REM Licensed under BSD 3-Clause (see main file or LICENSE)
REM v1.0

REM ################################################################################
REM # This script compiles all Papyrus scripts for Divine Logic using Bethesda's  #
REM # Papyrus Compiler. It copies source scripts to the Skyrim directory, then    #
REM # compiles them into the final output location.                               #
REM ################################################################################

REM 1️⃣ Set the path to the Papyrus Compiler
SET compiler="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe"

REM 2️⃣ Set the location of the Papyrus source scripts in Skyrim's Data folder
SET source="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source"

REM 4️⃣ Set the path to the mod's scripts being worked on
SET compile="C:\Users\Sjsho\Github\DivineLogic\Scripts\Source"

REM 5️⃣ Set the output directory for compiled scripts in Skyrim's Data folder
SET output="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts"

REM 6️⃣ Copy all modified source files to the Skyrim Scripts folder
XCOPY %compile%\* %source% /Y

REM 7️⃣ Compile the scripts using the Papyrus Compiler
%compiler% %compile% -all -f=%source%\TESV_Papyrus_Flags.flg -i=%source% -o=%output%

REM 8️⃣ Pause the script so the user can see the output before closing
PAUSE
