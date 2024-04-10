@echo off

rem : this requires dotnet SDK to be installed on your system in order to work
set ARGIN=%~1

if "%ARGIN%"=="" (
	echo This will automatically add 'dotnet-script'
	set /p target="Which directory? ( use forward slashes / ): "
) else (
	set target=%ARGIN%
)

dotnet tool install -g dotnet-script
if exist "%USERPROFILE%\tempscript.csx" del /f/q "%USERPROFILE%\tempscript.csx"
setlocal ENABLEDELAYEDEXPANSION

(
	echo private static string FormatBytes^(long bytes^)                                                                
	echo   {                                                                                                          
	echo       string[] Suffix = { "B", "KB", "MB", "GB", "TB" };                                                     
	echo       int i;                                                                                                 
	echo       double dblSByte = bytes;                                                                               
	echo       for ^(i = 0; i ^< Suffix.Length ^&^& bytes ^>= 1024; i^+^+, bytes /= 1024^)                                    
	echo       {                                                                                                      
	echo           dblSByte = bytes / 1024.0;                                                                         
	echo       }                                                                                                      
	echo       return String.Format^("{0:0.##} {1}", dblSByte, Suffix[i]^);                                             
	echo 	//																									 
	echo   }                                                                                                          
	echo 	//																										 
	echo   Func^<DirectoryInfo, long^> getDirInfo = ^(DirectoryInfo d^) =^> {                                              
	echo   try{    Console.Write^("."^);                                                                                
	echo       long size = 0;                                                                                         
	echo       // Add file sizes.                                                                                     
	echo       FileInfo[] fis = d.GetFiles^(^);                                                                         
	echo       foreach ^(FileInfo fi in fis^)                                                                           
	echo       {                                                                                                      
	echo           size ^+= fi.Length;                                                                                 
	echo       }                                                                                                      
	echo       // Add subdirectory sizes.                                                                             
	echo       DirectoryInfo[] dis = d.GetDirectories^(^);                                                              
	echo       foreach ^(DirectoryInfo di in dis^)                                                                      
	echo       {                                                                                                      
	echo           size ^+= getDirInfo^(di^);                                                                            
	echo       }                                                                                                      
	echo       return size;                                                                                           
	echo   }catch{                                                                                                    
	echo       Console.Write^("X"^);                                                                                    
	echo       return 0;                                                                                              
	echo   }                                                                                                          
	echo   };                                                                                                         
	echo 		//																									 
	echo   List^<Tuple^<string, long^>^> dirsInfo = new List^<Tuple^<string, long^>^>^(^);                                      
	echo   foreach^(var dir in Directory.GetDirectories^("%target%", "*", SearchOption.TopDirectoryOnly^)^){   
	echo 		//																									 
	echo   dirsInfo.Add^(new Tuple^<string, long^>^(dir, getDirInfo^(new DirectoryInfo^(dir^)^)^)^);                            
	echo   }                                                                                                          
	echo   dirsInfo.Sort^(^(a,b^) =^> b.Item2.CompareTo^(a.Item2^)^);                                                        
	echo   Console.WriteLine^(""^); // new line                                                                         
	echo   foreach^(var a in dirsInfo^){                                                                                
	echo       Console.WriteLine^($"{a.Item1} --- {FormatBytes(a.Item2)}"^);                                            
	echo   }                                                                                                  
) > "%USERPROFILE%\tempscript.csx"
endlocal
dotnet-script "%USERPROFILE%\tempscript.csx"

if exist "%USERPROFILE%\tempscript.csx" del /f/q "%USERPROFILE%\tempscript.csx"
echo DONE

pause