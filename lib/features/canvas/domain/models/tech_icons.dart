import 'package:flutter/material.dart';

enum TechIconCategory {
  all('All Icons', Icons.apps_rounded),
  cloudCompute('Cloud & Compute', Icons.cloud_outlined),
  databases('Databases & Storage', Icons.storage_rounded),
  networking('Networking & Messaging', Icons.hub_outlined),
  devops('DevOps & Containers', Icons.developer_board_rounded),
  clients('Clients & Devices', Icons.devices_rounded);

  final String label;
  final IconData icon;
  const TechIconCategory(this.label, this.icon);
}

class TechIconDefinition {
  final String id;
  final String name;
  final TechIconCategory category;
  final Color brandColor;
  final IconData icon;
  final String emoji;
  final String defaultLabel;
  final List<String> keywords;

  const TechIconDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.brandColor,
    required this.icon,
    required this.emoji,
    required this.defaultLabel,
    this.keywords = const [],
  });

  bool matches(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return true;
    if (name.toLowerCase().contains(clean)) return true;
    if (id.toLowerCase().contains(clean)) return true;
    if (defaultLabel.toLowerCase().contains(clean)) return true;
    if (category.label.toLowerCase().contains(clean)) return true;
    for (final kw in keywords) {
      if (kw.toLowerCase().contains(clean)) return true;
    }
    return false;
  }
}

class TechIconRegistry {
  const TechIconRegistry._();

  static const List<TechIconDefinition> icons = [
    // ── 1. Cloud & Compute ──────────────────────────────────────────────
    TechIconDefinition(
      id: 'aws_lambda',
      name: 'AWS Lambda',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFFFF9900),
      icon: Icons.bolt_rounded,
      emoji: '⚡',
      defaultLabel: 'AWS Lambda',
      keywords: ['serverless', 'function', 'faas', 'aws', 'amazon', 'compute'],
    ),
    TechIconDefinition(
      id: 'aws_ec2',
      name: 'AWS EC2',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFFFF9900),
      icon: Icons.memory_rounded,
      emoji: '🖥️',
      defaultLabel: 'EC2 Instance',
      keywords: ['vm', 'virtual machine', 'compute', 'aws', 'amazon', 'server'],
    ),
    TechIconDefinition(
      id: 'gcp_cloud_run',
      name: 'Google Cloud Run',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFF4285F4),
      icon: Icons.directions_run_rounded,
      emoji: '🏃',
      defaultLabel: 'Cloud Run',
      keywords: ['container', 'serverless', 'gcp', 'google', 'compute'],
    ),
    TechIconDefinition(
      id: 'gcp_compute',
      name: 'Google Compute Engine',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFF4285F4),
      icon: Icons.computer_rounded,
      emoji: '⚙️',
      defaultLabel: 'Compute Engine',
      keywords: ['vm', 'gcp', 'google', 'instance', 'server'],
    ),
    TechIconDefinition(
      id: 'azure_functions',
      name: 'Azure Functions',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFF0078D4),
      icon: Icons.flash_on_rounded,
      emoji: '⚡',
      defaultLabel: 'Azure Function',
      keywords: ['microsoft', 'azure', 'serverless', 'faas'],
    ),
    TechIconDefinition(
      id: 'cloudflare_workers',
      name: 'Cloudflare Worker',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFFF38020),
      icon: Icons.cloud_queue_rounded,
      emoji: '⛅',
      defaultLabel: 'Cloudflare Worker',
      keywords: ['edge', 'worker', 'cdn', 'cloudflare'],
    ),
    TechIconDefinition(
      id: 'server_rack',
      name: 'Dedicated Server',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFF4A5568),
      icon: Icons.dns_rounded,
      emoji: '🗄️',
      defaultLabel: 'Dedicated Server',
      keywords: ['bare metal', 'rack', 'host', 'datacenter'],
    ),
    TechIconDefinition(
      id: 'vm',
      name: 'Virtual Machine',
      category: TechIconCategory.cloudCompute,
      brandColor: Color(0xFF6366F1),
      icon: Icons.layers_rounded,
      emoji: '💻',
      defaultLabel: 'Virtual Machine',
      keywords: ['guest', 'vps', 'hypervisor'],
    ),

    // ── 2. Databases & Storage ──────────────────────────────────────────
    TechIconDefinition(
      id: 'postgresql',
      name: 'PostgreSQL',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF336791),
      icon: Icons.dataset_rounded,
      emoji: '🐘',
      defaultLabel: 'PostgreSQL',
      keywords: ['sql', 'relational', 'rdbms', 'postgres', 'db'],
    ),
    TechIconDefinition(
      id: 'mysql',
      name: 'MySQL',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF00758F),
      icon: Icons.data_array_rounded,
      emoji: '🐬',
      defaultLabel: 'MySQL DB',
      keywords: ['sql', 'mariadb', 'relational', 'db'],
    ),
    TechIconDefinition(
      id: 'mongodb',
      name: 'MongoDB',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF47A248),
      icon: Icons.eco_rounded,
      emoji: '🍃',
      defaultLabel: 'MongoDB',
      keywords: ['nosql', 'document', 'json', 'mongo', 'db'],
    ),
    TechIconDefinition(
      id: 'redis',
      name: 'Redis Cache',
      category: TechIconCategory.databases,
      brandColor: Color(0xFFDC382D),
      icon: Icons.flash_auto_rounded,
      emoji: '⚡',
      defaultLabel: 'Redis Cache',
      keywords: ['cache', 'in-memory', 'key-value', 'store', 'fast'],
    ),
    TechIconDefinition(
      id: 'aws_s3',
      name: 'AWS S3',
      category: TechIconCategory.databases,
      brandColor: Color(0xFFE25A1C),
      icon: Icons.folder_special_rounded,
      emoji: '🪣',
      defaultLabel: 'S3 Object Store',
      keywords: ['bucket', 'storage', 'blob', 'files', 'aws', 'amazon'],
    ),
    TechIconDefinition(
      id: 'dynamodb',
      name: 'DynamoDB',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF4053D6),
      icon: Icons.table_rows_rounded,
      emoji: '⚡',
      defaultLabel: 'DynamoDB',
      keywords: ['nosql', 'aws', 'key-value', 'document'],
    ),
    TechIconDefinition(
      id: 'elasticsearch',
      name: 'Elasticsearch',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF005571),
      icon: Icons.search_rounded,
      emoji: '🔎',
      defaultLabel: 'Elasticsearch',
      keywords: ['search', 'logs', 'elk', 'analytics', 'index'],
    ),
    TechIconDefinition(
      id: 'sqlite',
      name: 'SQLite',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF003B57),
      icon: Icons.storage_rounded,
      emoji: '🪶',
      defaultLabel: 'SQLite DB',
      keywords: ['embedded', 'local', 'sql', 'mobile'],
    ),
    TechIconDefinition(
      id: 'storage_volume',
      name: 'Block Storage',
      category: TechIconCategory.databases,
      brandColor: Color(0xFF718096),
      icon: Icons.disc_full_rounded,
      emoji: '💾',
      defaultLabel: 'Storage Volume',
      keywords: ['ebs', 'disk', 'ssd', 'drive', 'volume'],
    ),

    // ── 3. Networking & Messaging ───────────────────────────────────────
    TechIconDefinition(
      id: 'api_gateway',
      name: 'API Gateway',
      category: TechIconCategory.networking,
      brandColor: Color(0xFF8B5CF6),
      icon: Icons.alt_route_rounded,
      emoji: '🚪',
      defaultLabel: 'API Gateway',
      keywords: ['proxy', 'routing', 'rest', 'graphql', 'endpoints'],
    ),
    TechIconDefinition(
      id: 'apache_kafka',
      name: 'Apache Kafka',
      category: TechIconCategory.networking,
      brandColor: Color(0xFF231F20),
      icon: Icons.stream_rounded,
      emoji: '📨',
      defaultLabel: 'Kafka Stream',
      keywords: ['event', 'stream', 'pubsub', 'queue', 'broker'],
    ),
    TechIconDefinition(
      id: 'rabbitmq',
      name: 'RabbitMQ',
      category: TechIconCategory.networking,
      brandColor: Color(0xFFFF6600),
      icon: Icons.move_to_inbox_rounded,
      emoji: '🐇',
      defaultLabel: 'RabbitMQ Queue',
      keywords: ['amqp', 'queue', 'messaging', 'broker'],
    ),
    TechIconDefinition(
      id: 'load_balancer',
      name: 'Load Balancer',
      category: TechIconCategory.networking,
      brandColor: Color(0xFF3B82F6),
      icon: Icons.call_split_rounded,
      emoji: '⚖️',
      defaultLabel: 'Load Balancer',
      keywords: ['alb', 'nlb', 'traffic', 'distribution', 'ha'],
    ),
    TechIconDefinition(
      id: 'nginx',
      name: 'Nginx Proxy',
      category: TechIconCategory.networking,
      brandColor: Color(0xFF009639),
      icon: Icons.swap_horiz_rounded,
      emoji: '🚦',
      defaultLabel: 'Nginx Proxy',
      keywords: ['reverse proxy', 'web server', 'routing'],
    ),
    TechIconDefinition(
      id: 'router',
      name: 'Network Router',
      category: TechIconCategory.networking,
      brandColor: Color(0xFF2563EB),
      icon: Icons.router_rounded,
      emoji: '📡',
      defaultLabel: 'Core Router',
      keywords: ['gateway', 'switch', 'network', 'ip'],
    ),
    TechIconDefinition(
      id: 'firewall',
      name: 'Firewall / WAF',
      category: TechIconCategory.networking,
      brandColor: Color(0xFFEF4444),
      icon: Icons.security_rounded,
      emoji: '🛡️',
      defaultLabel: 'Firewall / WAF',
      keywords: ['security', 'shield', 'ddos', 'protection'],
    ),
    TechIconDefinition(
      id: 'dns',
      name: 'DNS Resolver',
      category: TechIconCategory.networking,
      brandColor: Color(0xFF10B981),
      icon: Icons.language_rounded,
      emoji: '🌐',
      defaultLabel: 'DNS Resolver',
      keywords: ['domain', 'route53', 'cloudflare dns', 'nameserver'],
    ),
    TechIconDefinition(
      id: 'webhook',
      name: 'Webhook Event',
      category: TechIconCategory.networking,
      brandColor: Color(0xFFEC4899),
      icon: Icons.notifications_active_rounded,
      emoji: '🔔',
      defaultLabel: 'Webhook Event',
      keywords: ['trigger', 'callback', 'notification', 'http post'],
    ),

    TechIconDefinition(
      id: 'cloudflare',
      name: 'Cloudflare',
      category: TechIconCategory.networking,
      brandColor: Color(0xFFF38020),
      icon: Icons.shield_outlined,
      emoji: '🟧',
      defaultLabel: 'Cloudflare Edge',
      keywords: ['cdn', 'waf', 'ddos', 'edge', 'proxy', 'workers'],
    ),

    // ── 4. DevOps & Containers ──────────────────────────────────────────
    TechIconDefinition(
      id: 'docker',
      name: 'Docker',
      category: TechIconCategory.devops,
      brandColor: Color(0xFF2496ED),
      icon: Icons.all_inbox_rounded,
      emoji: '🐋',
      defaultLabel: 'Docker Container',
      keywords: ['container', 'image', 'compose', 'dock'],
    ),
    TechIconDefinition(
      id: 'kubernetes',
      name: 'Kubernetes',
      category: TechIconCategory.devops,
      brandColor: Color(0xFF326CE5),
      icon: Icons.control_camera_rounded,
      emoji: '☸️',
      defaultLabel: 'K8s Cluster',
      keywords: ['k8s', 'cluster', 'pod', 'orchestration', 'deployment'],
    ),
    TechIconDefinition(
      id: 'github',
      name: 'GitHub',
      category: TechIconCategory.devops,
      brandColor: Color(0xFF24292E),
      icon: Icons.code_rounded,
      emoji: '🐙',
      defaultLabel: 'GitHub',
      keywords: ['git', 'repo', 'version control', 'actions'],
    ),
    TechIconDefinition(
      id: 'gitlab',
      name: 'GitLab',
      category: TechIconCategory.devops,
      brandColor: Color(0xFFFC6D26),
      icon: Icons.merge_type_rounded,
      emoji: '🦊',
      defaultLabel: 'GitLab Pipeline',
      keywords: ['git', 'ci', 'cd', 'pipeline'],
    ),
    TechIconDefinition(
      id: 'cicd',
      name: 'CI/CD Pipeline',
      category: TechIconCategory.devops,
      brandColor: Color(0xFF059669),
      icon: Icons.sync_alt_rounded,
      emoji: '🔄',
      defaultLabel: 'CI/CD Pipeline',
      keywords: ['automation', 'build', 'deploy', 'runner', 'actions'],
    ),
    TechIconDefinition(
      id: 'jenkins',
      name: 'Jenkins',
      category: TechIconCategory.devops,
      brandColor: Color(0xFFD33833),
      icon: Icons.build_circle_outlined,
      emoji: '🤵',
      defaultLabel: 'Jenkins CI',
      keywords: ['ci', 'cd', 'build', 'automation', 'pipeline'],
    ),
    TechIconDefinition(
      id: 'terminal',
      name: 'CLI / Worker',
      category: TechIconCategory.devops,
      brandColor: Color(0xFF1E293B),
      icon: Icons.terminal_rounded,
      emoji: '⌨️',
      defaultLabel: 'Worker Process',
      keywords: ['cron', 'daemon', 'script', 'background', 'bash'],
    ),

    // ── 5. Clients & Devices ────────────────────────────────────────────
    TechIconDefinition(
      id: 'web_browser',
      name: 'Web Browser',
      category: TechIconCategory.clients,
      brandColor: Color(0xFF3B82F6),
      icon: Icons.web_rounded,
      emoji: '🌐',
      defaultLabel: 'Web Client',
      keywords: ['frontend', 'browser', 'chrome', 'html', 'spa'],
    ),
    TechIconDefinition(
      id: 'mobile_app',
      name: 'Mobile App',
      category: TechIconCategory.clients,
      brandColor: Color(0xFF10B981),
      icon: Icons.smartphone_rounded,
      emoji: '📱',
      defaultLabel: 'Mobile App',
      keywords: ['ios', 'android', 'flutter', 'react native', 'phone'],
    ),
    TechIconDefinition(
      id: 'desktop_app',
      name: 'Desktop App',
      category: TechIconCategory.clients,
      brandColor: Color(0xFF6366F1),
      icon: Icons.desktop_windows_rounded,
      emoji: '🖥️',
      defaultLabel: 'Desktop Client',
      keywords: ['macos', 'windows', 'linux', 'electron', 'client'],
    ),
    TechIconDefinition(
      id: 'tablet_client',
      name: 'Tablet Client',
      category: TechIconCategory.clients,
      brandColor: Color(0xFF8B5CF6),
      icon: Icons.tablet_mac_rounded,
      emoji: '📲',
      defaultLabel: 'Tablet Device',
      keywords: ['ipad', 'tablet', 'touch'],
    ),
    TechIconDefinition(
      id: 'user_actor',
      name: 'End User / Actor',
      category: TechIconCategory.clients,
      brandColor: Color(0xFFF59E0B),
      icon: Icons.person_outline_rounded,
      emoji: '👤',
      defaultLabel: 'End User',
      keywords: ['actor', 'customer', 'client', 'admin'],
    ),
    TechIconDefinition(
      id: 'iot_device',
      name: 'IoT Sensor',
      category: TechIconCategory.clients,
      brandColor: Color(0xFF06B6D4),
      icon: Icons.sensors_rounded,
      emoji: '📟',
      defaultLabel: 'IoT Sensor',
      keywords: ['hardware', 'sensor', 'embedded', 'telemetry'],
    ),
    TechIconDefinition(
      id: 'auth_service',
      name: 'Auth & Identity',
      category: TechIconCategory.clients,
      brandColor: Color(0xFFD97706),
      icon: Icons.lock_outline_rounded,
      emoji: '🔐',
      defaultLabel: 'Auth & IAM',
      keywords: ['oauth', 'jwt', 'login', 'security', 'iam', 'keycloak'],
    ),
  ];

  static TechIconDefinition? findById(String id) {
    for (final icon in icons) {
      if (icon.id == id) return icon;
    }
    return null;
  }

  static List<TechIconDefinition> filter({
    String query = '',
    TechIconCategory category = TechIconCategory.all,
  }) {
    return icons.where((icon) {
      final matchesCategory = category == TechIconCategory.all || icon.category == category;
      return matchesCategory && icon.matches(query);
    }).toList();
  }
}
