"""
Utility functions for the crew project.
"""
import os
import shutil
from datetime import datetime
from typing import List
from crewai import Task
from crewai.agents.agent_builder.base_agent import BaseAgent


def generate_output_filename(prefix: str = "crew-report") -> str:
    """
    Generate a timestamped filename for outputs.
    
    Args:
        prefix: The prefix for the filename (default: "crew-report")
        
    Returns:
        str: Timestamped filename in format: prefix_YYYY-MM-DD_HH-MM-SS.md
    """
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    return f"output/{prefix}_{timestamp}.md"


def ensure_output_directory() -> None:
    """
    Ensure the output directory exists.
    """
    os.makedirs("output", exist_ok=True)


def clear_output_directory() -> None:
    """
    Clear all files from the output directory.
    """
    if os.path.exists("output"):
        # Remove all files in the output directory
        for filename in os.listdir("output"):
            file_path = os.path.join("output", filename)
            try:
                if os.path.isfile(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                print(f"Error deleting {file_path}: {e}")
        print("🗑️ Output directory cleared!")
    else:
        print("📁 Output directory doesn't exist, nothing to clear.")


def create_crew_tasks_with_output(tasks_config: dict, research_task_func, output_file: str) -> List[Task]:
    """
    Create a list of tasks with a custom output file for the reporting task.
    
    Args:
        tasks_config: The tasks configuration dictionary
        research_task_func: Function to create the research task
        output_file: Path for the output file
        
    Returns:
        List[Task]: List of tasks with custom output file
    """
    # Create research task
    research_task = research_task_func()
    
    # Create reporting task with custom output file
    reporting_task = Task(
        config=tasks_config['reporting_task'],
        output_file=output_file
    )
    
    return [research_task, reporting_task]


def get_crew_inputs(topic: str = "AI LLMs") -> dict:
    """
    Get standard inputs for crew execution.
    
    Args:
        topic: The research topic (default: "AI LLMs")
        
    Returns:
        dict: Standard inputs dictionary
    """
    return {
        'topic': topic,
        'current_year': str(datetime.now().year)
    } 