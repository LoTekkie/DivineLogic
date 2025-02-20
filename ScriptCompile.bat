set compiler="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe"
set source="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source"
rem Change version to the current version being worked on before executing
set version=0.9.4
set compile="C:\Users\Sjsho\Github\DivineLogic\v%version%\Scripts\Source"
set output="C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts"
xcopy %compile%\* %source% /Y
%compiler% %compile% -all -f=%source%\TESV_Papyrus_Flags.flg -i=%source% -o=%output%
pause