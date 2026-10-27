# Official Keycloak, pre-built for Postgres and a single node, so the
# container starts with `start --optimized` instead of re-augmenting on boot.
FROM quay.io/keycloak/keycloak:26.8.1 AS builder
ENV KC_DB=postgres KC_CACHE=local
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.8.1
COPY --from=builder /opt/keycloak/ /opt/keycloak/
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
