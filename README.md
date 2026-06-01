# idle-shutdown-guard

Небольшая пользовательская служба для RPM-based Linux систем. После заданного
часа она проверяет неактивность пользователя. Если пользователь неактивен
час, появляется окно предупреждения. Выключение можно отложить на час. Если
за 5 минут его не отложить, запускается команда выключения.

## Как это работает

- Служба запускается в пользовательской systemd-сессии.
- Если доступен GTK, программа показывает иконку в системном трее. Через меню
  можно открыть статус, изменить настройки, запустить проверку вручную или
  выйти из программы.
- При установке пакета добавляется XDG-autostart файл, поэтому программа
  запускается в графической сессии пользователя автоматически.
- Активность определяется через `xprintidle` на X11, если он установлен.
- Если `xprintidle` недоступен, используется `systemd-logind`.
- Диалог показывается через `zenity`, затем через `kdialog`, затем через
  критическое уведомление `notify-send` без возможности отложить.
- После отсрочки служба не выключает компьютер только по таймеру. Когда
  отсрочка закончилась, она снова проверяет реальную неактивность: если
  активности не было, предупреждение появится снова; если пользователь работал,
  отсчёт неактивности начинается заново.
- Выключение по умолчанию выполняется командой:

```bash
systemctl poweroff --ignore-inhibitors
```

## Настройка

Системный конфиг:

```text
/etc/idle-shutdown-guard/config.ini
```

Пользовательский конфиг, который перекрывает системный:

```text
~/.config/idle-shutdown-guard/config.ini
```

Пример:

```ini
[settings]
tray_enabled = yes
begin_hour = 22
idle_minutes = 60
warning_timeout_minutes = 5
defer_minutes = 60
check_interval_seconds = 60
shutdown_command = systemctl poweroff --ignore-inhibitors
```

`begin_hour = 22` означает, что проверка выполняется с 22:00 до 23:59.

`tray_enabled = yes` включает иконку в трее. Если GTK или системный трей
недоступны, служба автоматически продолжит работу без иконки.

Настройки из формы сохраняются в:

```text
~/.config/idle-shutdown-guard/config.ini
```

## Ручная установка без RPM

```bash
sudo install -Dpm0755 src/idle-shutdown-guard /usr/bin/idle-shutdown-guard
sudo install -Dpm0644 config/config.ini /etc/idle-shutdown-guard/config.ini
sudo install -Dpm0644 systemd/idle-shutdown-guard.service /usr/lib/systemd/user/idle-shutdown-guard.service
sudo install -Dpm0644 desktop/idle-shutdown-guard.desktop /etc/xdg/autostart/idle-shutdown-guard.desktop
sudo install -Dpm0644 icons/idle-shutdown-guard.svg /usr/share/icons/hicolor/scalable/apps/idle-shutdown-guard.svg
systemctl --user daemon-reload
systemctl --user enable --now idle-shutdown-guard.service
```

Чтобы служба продолжала работать после выхода из сессии, можно включить linger:

```bash
sudo loginctl enable-linger "$USER"
```

Обычно для настольного ПК linger не нужен: служба должна работать именно пока
открыта пользовательская графическая сессия.

## Сборка RPM

RPM и DEB можно собрать одной командой на Linux-машине с `rpmbuild` и
`dpkg-deb`:

```bash
bash scripts/build-packages.sh 0.2.2
```

Готовые файлы появятся в `dist/`.

Ручной вариант для RPM:

```bash
mkdir -p ~/rpmbuild/SOURCES
tar --transform 's,^,idle-shutdown-guard-0.2.2/,' \
  -czf ~/rpmbuild/SOURCES/idle-shutdown-guard-0.2.2.tar.gz \
  src config desktop icons systemd packaging
rpmbuild -ba packaging/idle-shutdown-guard.spec
```

## GitHub Release

Workflow `.github/workflows/release-packages.yml` собирает `.rpm`, `.src.rpm`,
`.deb` и архив исходников, затем прикладывает их к GitHub Release. Он
запускается автоматически при пуше тега `v*`, либо вручную через
`workflow_dispatch` с номером версии.

## RedADM и RedOS 8

RPM-пакет можно распространять на RedOS 8 через RedADM. Памятка лежит в
`docs/redadm-redos8.md`.

После установки:

```bash
systemctl --user daemon-reload
systemctl --user enable --now idle-shutdown-guard.service
```

## Проверка

Для теста можно временно поставить:

```ini
[settings]
tray_enabled = yes
begin_hour = 0
idle_minutes = 1
warning_timeout_minutes = 1
defer_minutes = 1
shutdown_command = notify-send "Тест выключения" "Команда выключения не запускалась"
```

После проверки верните настоящую команду выключения.
