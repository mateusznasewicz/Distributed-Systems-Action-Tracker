# Projekt 2: Cloud Infrastructure & Deployment

Projekt ten stanowi rozszerzenie aplikacji webowej z Projektu 1, wdrażając ją w środowisku chmurowym AWS przy użyciu podejścia Infrastructure as Code (IaC).

Celem projektu jest stworzenie kompletnej, skalowalnej infrastruktury obejmującej aplikację, bazę danych, system uwierzytelniania, storage plików oraz monitoring.

## 🛠️ Stos technologiczny

Projekt wykorzystuje następujące technologie i narzędzia:

* **Chmura:** AWS (EC2 / ECS Fargate) [cite: 4]
* **IaC:** Terraform [cite: 6]
* **Auth:** Keycloak [cite: 7]
* **Storage:** MinIO (S3-compatible) [cite: 8]
* **Baza danych:** PostgreSQL / MongoDB (Self-hosted) [cite: 9]
* **Monitoring:** Prometheus & Grafana [cite: 10]

---

## 🚀 Infrastruktura i Funkcjonalności

Cała infrastruktura jest definiowana i zarządzana za pomocą Terraform[cite: 5, 6]. Poniżej znajduje się opis poszczególnych serwisów:

### 1. Aplikacja Webowa
Główna aplikacja została rozszerzona i jest hostowana w chmurze AWS.

### 2. Uwierzytelnianie (Keycloak)
Zarządzanie tożsamością i dostępem zostało zrealizowane przy użyciu Keycloak.
* Zapewnia bezpieczne logowanie i rejestrację użytkowników[cite: 7].
* Dokumentacja: [Keycloak Docs](https://www.keycloak.org/documentation)[cite: 11].

### 3. Object Storage (MinIO)
Do przechowywania plików multimedialnych wykorzystano MinIO, które oferuje API kompatybilne z Amazon S3.
* Samodzielnie hostowana instancja do obsługi uploadu i downloadu plików[cite: 8].
* Dokumentacja: [MinIO Docs](https://docs.min.io/enterprise/aistor-object-store/)[cite: 12].

### 4. Baza Danych
Dane aplikacji są przechowywane w samodzielnie hostowanej bazie danych (PostgreSQL lub MongoDB), uruchomionej wewnątrz infrastruktury[cite: 9].

### 5. Monitoring (Prometheus + Grafana)
Zaimplementowano pełny stack monitoringowy[cite: 10]:
* **Prometheus:** Zbieranie metryk z aplikacji i infrastruktury[cite: 13].
* **Grafana:** Wizualizacja danych i dashboardy analityczne[cite: 14].

---

## ⚙️ Wymagania wstępne

Aby uruchomić projekt lokalnie lub wdrożyć go na AWS, potrzebujesz:

* [AWS CLI](https://aws.amazon.com/cli/) (skonfigurowane z odpowiednimi uprawnieniami)
* [Terraform](https://www.terraform.io/) (wersja 1.0+)
* Docker (opcjonalnie, do testów lokalnych)



## 🔌 Dostęp do serwisów

Po poprawnym wdrożeniu, Terraform zwróci adresy IP lub domeny poszczególnych usług (Outputs). Domyślne porty (jeśli nie zmieniono w konfiguracji):

| Serwis | Port | Opis |
| :--- | :--- | :--- |
| **Web App** | `80` / `443` | Główna aplikacja |
| **Keycloak** | `8080` | Panel administratora Keycloak |
| **MinIO** | `9000` / `9001` | Konsola i API MinIO |
| **Grafana** | `3000` | Dashboardy monitoringu |
| **Prometheus**| `9090` | Interfejs Prometheus |

-----

## 🧹 Czyszczenie zasobów (Destroy)

Aby usunąć całą infrastrukturę i uniknąć naliczania kosztów w AWS:

```bash
terraform destroy
```
