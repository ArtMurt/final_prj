<!DOCTYPE html>
<html>
<head>
<title>Cyber-ED S-410-7_S-224</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Cyber-ED S-410-7_S-224</h1>
<p>Получен доступ приложению <?php print $_SERVER['SERVER_SOFTWARE']; ?> на сервере: <b><?php print gethostname(); ?></b></p>
<p>Устройство с которого инициировано подключение:  <br><b><?php print $_SERVER['HTTP_USER_AGENT']; ?></b></p>
<p>IP-адрес сервера: <?php print $_SERVER['SERVER_ADDR']; ?> IP-адрес источника: <?php print $_SERVER['REMOTE_ADDR']; ?></p>
</body>
</html>