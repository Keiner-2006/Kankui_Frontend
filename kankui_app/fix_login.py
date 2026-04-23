with open('lib/screens/login_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Revertir el cambio anterior que metió demasiados saltos
# Buscar y eliminar las líneas en blanco extra
content = content.replace('\n\n\n\n    try {', '\n    try {')
content = content.replace('\n\n    try {', '\n    try {')

# Limpiar espacios en blanco extras
lines = content.split('\n')
cleaned_lines = []
prev_empty = False
for line in lines:
    if line.strip() == '':
        if not prev_empty:
            cleaned_lines.append(line)
            prev_empty = True
    else:
        cleaned_lines.append(line)
        prev_empty = False

content = '\n'.join(cleaned_lines)

with open('lib/screens/login_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Limpiado exitosamente')
