ARG DOTNET_VERSION=10.0

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
ARG YARP_PACKAGE_VERSION=2.3.0
WORKDIR /src
COPY YarpProxy.csproj .
RUN dotnet restore -p:YarpVersion=${YARP_PACKAGE_VERSION}
COPY . .
RUN dotnet publish -c Release -o /app --no-restore -p:YarpVersion=${YARP_PACKAGE_VERSION}

FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION}
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "YarpProxy.dll"]
