#!/usr/bin/env python
import sys
import warnings
import os
from dotenv import load_dotenv
import agentops
load_dotenv()

# Initialize AgentOps only if API key is provided
agentops_api_key = os.getenv("AGENTOPS_API_KEY")
if agentops_api_key:
    agentops.init(api_key=agentops_api_key)
    print("🔍 AgentOps observability enabled - view traces at: https://app.agentops.ai/traces")
else:
    print("ℹ️  AgentOps API key not found - running without observability")
    print("   Get your key at: https://app.agentops.ai/settings/projects")

from crew.crew import Crew
from crew.utils import generate_output_filename, ensure_output_directory, get_crew_inputs, clear_output_directory

warnings.filterwarnings("ignore", category=SyntaxWarning, module="pysbd")

# This main file is intended to be a way for you to run your
# crew locally, so refrain from adding unnecessary logic into this file.
# Replace with inputs you want to test with, it will automatically
# interpolate any tasks and agents information

def run():
    """
    Run the crew.
    """
    # Ensure output directory exists and generate filename
    ensure_output_directory()
    output_file = generate_output_filename()
    
    # Get standard inputs
    inputs = get_crew_inputs()
    
    try:
        result = Crew().crew_with_output_file(output_file).kickoff(inputs=inputs)
        print(f"\n🎉 Crew completed successfully!")
        print(f"📄 Report saved to: {output_file}")
        if agentops_api_key:
            print(f"🔍 View execution trace at: https://app.agentops.ai/traces")
        return result
    except Exception as e:
        raise Exception(f"An error occurred while running the crew: {e}")


def train():
    """
    Train the crew for a given number of iterations.
    """
    # Ensure output directory exists and generate filename
    ensure_output_directory()
    output_file = generate_output_filename("crew-training")
    
    # Get standard inputs
    inputs = get_crew_inputs()
    
    try:
        Crew().crew_with_output_file(output_file).train(n_iterations=int(sys.argv[1]), filename=sys.argv[2], inputs=inputs) 

    except Exception as e:
        raise Exception(f"An error occurred while training the crew: {e}")

def replay():
    """
    Replay the crew execution from a specific task.
    """
    try:
        Crew().crew().replay(task_id=sys.argv[1])

    except Exception as e:
        raise Exception(f"An error occurred while replaying the crew: {e}")

def test():
    """
    Test the crew execution and returns the results.
    """
    # Ensure output directory exists and generate filename
    ensure_output_directory()
    output_file = generate_output_filename("crew-test")
    
    # Get standard inputs
    inputs = get_crew_inputs()
    
    try:
        Crew().crew_with_output_file(output_file).test(n_iterations=int(sys.argv[1]), eval_llm=sys.argv[2], inputs=inputs)

    except Exception as e:
        raise Exception(f"An error occurred while testing the crew: {e}")

def clear():
    """
    Clear all output files.
    """
    try:
        clear_output_directory()
    except Exception as e:
        raise Exception(f"An error occurred while clearing outputs: {e}")
