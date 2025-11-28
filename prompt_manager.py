"""
Gestionnaire de prompts système prédéfinis
"""

import json
import os

PROMPTS_DIR = "prompts"
CONFIG_FILE = os.path.join(PROMPTS_DIR, "prompts_config.json")


def load_prompts_config():
    """Charge la configuration des prompts disponibles"""
    try:
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {"prompts": []}


def get_available_prompts():
    """Retourne la liste des prompts disponibles"""
    config = load_prompts_config()
    return config.get("prompts", [])


def get_default_prompt_id():
    """Retourne l'ID du prompt par défaut"""
    prompts = get_available_prompts()
    for prompt in prompts:
        if prompt.get("default", False):
            return prompt["id"]
    # Si aucun prompt par défaut, retourner le premier
    return prompts[0]["id"] if prompts else None


def get_prompt_by_id(prompt_id):
    """Retourne le contenu d'un prompt par son ID"""
    prompts = get_available_prompts()
    for prompt in prompts:
        if prompt["id"] == prompt_id:
            file_path = os.path.join(PROMPTS_DIR, prompt["file"])
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    return f.read()
            except FileNotFoundError:
                return None
    return None


def get_prompt_info(prompt_id):
    """Retourne les informations sur un prompt"""
    prompts = get_available_prompts()
    for prompt in prompts:
        if prompt["id"] == prompt_id:
            return prompt
    return None
