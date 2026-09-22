"""Sync the reviewed canonical contract to the frontend; --check is a CI guard."""
import argparse
from pathlib import Path

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--frontend", type=Path, default=Path(__file__).resolve().parents[2] / "langfens-fe-app")
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[1] / "services/ai-service/app/prompts/autogen_contract.json"
    target = args.frontend / "src/app/admin/_lib/autogenContract.json"
    if args.check:
        if not target.exists() or target.read_bytes() != source.read_bytes():
            raise SystemExit("Autogen contract drift: run scripts/sync_autogen_contract.py")
        print("Autogen contract mirrors match")
    else:
        target.write_bytes(source.read_bytes())
        print(f"Synced {target}")

if __name__ == "__main__":
    main()
