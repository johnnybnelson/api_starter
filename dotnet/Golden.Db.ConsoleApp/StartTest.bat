SET IsWatcherDisabled=false
:: dotnet test bin\Debug\net7.0\Sabio.Db.ConsoleApp.Tests.dll -l "trx;verbosity=detailed" -s "./default.runsettings" --filter "FullyQualifiedName~Friend | FullyQualifiedName~User | FullyQualifiedName~Address"
TestExecutables\Sabio.Db.ConsoleApp.TestResults.exe -a \\bin\\Debug\\net7.0 -d \\TestResults -t \\lib -f "FullyQualifiedName~Friend|FullyQualifiedName~User|FullyQualifiedName~Address"
pause

