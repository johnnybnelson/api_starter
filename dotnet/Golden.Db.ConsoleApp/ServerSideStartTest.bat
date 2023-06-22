:: dotnet test bin\Debug\net7.0\Sabio.Db.ConsoleApp.Tests.dll -l "trx;verbosity=detailed" -s "./serverside.runsettings" --filter "FullyQualifiedName~Concerts"
SET IsWatcherDisabled=false
TestExecutables\Sabio.Db.ConsoleApp.TestResults.exe -a \\bin\\Debug\\net7.0 -d \\TestResults -t \\lib -f "FullyQualifiedName~Concerts"