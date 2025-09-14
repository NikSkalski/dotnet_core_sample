FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore


FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
RUN addgroup -g 1001 -S appgroup \
    && adduser -S appuser -G appgroup -u 1001 \
    && apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        tzdata \
        openssl \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/* /tmp/*
WORKDIR /app
COPY --from=build /app/publish .
RUN chown -R appuser:appgroup /app
USER appuser

ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "dotnet_core_sample.dll"]
