FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore


FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS runtime
RUN addgroup -g 1001 -S appgroup \
    && adduser -S appuser -G appgroup -u 1001 \
    && apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        tzdata \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/* /tmp/*
WORKDIR /app
COPY --from=build /app/publish .
RUN chown -R appuser:appgroup /app
USER appuser

ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "pipelines-dotnet-core.dll"]
