import re
import pathlib

"""Convertit `Type name,` + `: _name = name` en `Type this._name,`.

Le nom public du paramètre reste `name`, donc les sites d'appel ne changent pas.
Ne traite que les clauses dont le membre droit est un vrai paramètre : les
affectations internes (`_isInitialized = true`) sont laissées intactes.
"""

root = pathlib.Path("lib")
changed = []

CLAUSE = re.compile(
    r"\n\s*_[A-Za-z0-9_]+ = (?P<param>[A-Za-z0-9_]+)\s*[;,]"
)

for path in sorted(root.rglob("*.dart")):
    text = path.read_text(encoding="utf-8")
    original = text
    converted = []

    # Parcours itératif : retirer une clause modifie les positions.
    while True:
        target = None
        for m in CLAUSE.finditer(text):
            param = m.group("param")
            # Le paramètre doit être déclaré dans une liste de paramètres.
            decl = (
                r"\s+(?:required\s+)?[A-Za-z0-9_<>,\s\?\.]+"
                + re.escape(param)
                + r"\s*,"
            )
            if re.search(decl, text):
                target = m
                break

        if target is None:
            break

        param = target.group("param")

        # 1. Retirer la clause de la liste d'initialisation.
        text = text[: target.start()] + text[target.end():]

        # 2. Réécrire la déclaration du paramètre en forme initialisante.
        text, count = re.subn(
            r"(\s+(?:required\s+)?)([A-Za-z0-9_<>,\s\?\.]+)("
            + re.escape(param)
            + r")(\s*,)",
            lambda d: f"{d.group(1)}{d.group(2)}this._{param}{d.group(4)}",
            text,
            count=1,
        )
        if count == 0:
            raise SystemExit(f"{path}: paramètre '{param}' introuvable")
        converted.append(param)

    # Nettoie les listes d'initialisation devenues vides.
    text = re.sub(r"\)\s*:\s*\n(\s*\))", r")\1", text)
    text = re.sub(r"\)\s*:\s*\n(\s*\}\))", r")\n\1", text)
    text = re.sub(r"\n\s*;\s*\n", "\n", text)

    if text != original:
        path.write_text(text, encoding="utf-8")
        changed.append(f"{path}: {', '.join(converted)}")

print("\n".join(changed) if changed else "aucun changement")