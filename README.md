# K8SSS

**K8s Simple Stupid Scripts** — a personal grab-bag of manifests, Docker Compose
files, and Ansible playbooks for spinning up common data infrastructure
(Kafka, Redis, MariaDB, PostgreSQL, Flink) on Kubernetes, Docker, or plain VMs.

These are scratch/lab configs meant for local experimentation and learning, not
production. Credentials are hardcoded and clusters are minimally hardened.

## Layout

| Directory  | What's inside                                                                    |
|------------|----------------------------------------------------------------------------------|
| `kafka/`   | Kafka deployments: a 3-node KRaft cluster with SASL via Docker Compose (`docker-compose.yml`), a K8s `StatefulSet` (`kafka.yaml`), a Strimzi operator manifest (`kafka-strimzi.yaml`), and a JAAS config (`kafka_server_jaas.conf`). |
| `redis/`   | A 6-node Redis cluster (3 masters / 3 replicas) via Docker Compose, with `redis.conf` and an auto cluster-init container. |
| `maria/`   | MariaDB on Kubernetes: `Deployment` plus a `PersistentVolume` / `PersistentVolumeClaim`. |
| `flink/`   | Flink session-cluster manifests: config `ConfigMap`, JobManager service + deployment (non-HA), and TaskManager deployment. |
| `coredns/` | CoreDNS custom `ConfigMap` for cluster DNS overrides/forwarding.                 |
| `test/`    | Throwaway test manifests: an nginx `Deployment` + `Service` and a `dnsutils` debug pod. |
| `play/`    | Ansible playbooks that provision services directly on VMs (see below).           |
| `config/`  | Scratch space for ad-hoc configs.                                                |
| `venv/`    | Local Python virtualenv with Ansible (git-ignored).                              |

## Ansible playbooks (`play/`)

Each subfolder ships a playbook and an example inventory (`*.example`). Copy the
example to `hosts` (the real `hosts` file is git-ignored), fill in your VM IPs,
users, and vars, then run with `ansible-playbook`.

- **`play/redis/`** — provisions a Redis cluster across `master`/`slave` hosts
  from `redis.conf`, including topology setup. Inventory: `host.example`.
- **`play/kafka/`** — provisions a Kafka KRaft cluster across `broker` hosts,
  templating the stock Kafka `config/` (node id, quorum voters, listeners).
- **`play/postgres/`** — builds PostgreSQL + the `pgvector` extension from source
  into a user's home directory; `restart.yaml` restarts the instance.
  Inventory: `hosts.example`.

## Usage

### Docker Compose (local clusters)

```bash
# 3-node Kafka KRaft cluster with SASL/PLAIN
cd kafka && docker compose up -d
# external brokers: localhost:9092, localhost:9094, localhost:9095
# SASL user/pass: admin / admin-secret (also client / client-secret)

# 6-node Redis cluster (ports 7001-7006)
cd redis && docker compose up -d
# the redis-cluster-init container forms the cluster automatically
```

### Kubernetes

```bash
kubectl apply -f maria/persistent-vol.yaml -f maria/persistent-vol-claim.yaml
kubectl apply -f maria/mariadb-deployment.yaml

kubectl apply -f kafka/kafka.yaml          # plain StatefulSet
kubectl apply -f kafka/kafka-strimzi.yaml  # requires the Strimzi operator

kubectl apply -f flink/                    # Flink session cluster
kubectl apply -f coredns/coredns-custom-config.yaml
kubectl apply -f test/nginx.yaml           # sanity check
```

### Ansible (VM provisioning)

```bash
source venv/bin/activate          # or install ansible yourself
cd play/postgres
cp hosts.example hosts            # edit with your hosts/vars
ansible-playbook -i hosts postgres.yaml
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
