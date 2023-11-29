FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.18-amd64 AS base
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.18-amd64 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["demo.api/demo.api.csproj", "demo.api/"]
RUN dotnet restore "demo.api/demo.api.csproj"  -r linux-musl-x64
COPY . .
WORKDIR "/src/demo.api"

FROM build AS publish
RUN dotnet publish "demo.api.csproj" -c Release -p:IsDocker=true -p:buildOS=linux --no-restore -r linux-musl-x64 --self-contained false -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "demo.api.dll"]