from crewai import Agent, Crew as CrewAI, Process, Task
from crewai.project import CrewBase, agent, crew, task
from crewai.agents.agent_builder.base_agent import BaseAgent
from typing import List
from dotenv import load_dotenv
from crew.utils import create_crew_tasks_with_output

load_dotenv()

# If you want to run a snippet of code before or after the crew starts,
# you can use the @before_kickoff and @after_kickoff decorators
# https://docs.crewai.com/concepts/crews#example-crew-class-with-decorators


@CrewBase
class Crew():
    """Your AI Crew"""

    agents: List[BaseAgent]
    tasks: List[Task]

    # Learn more about YAML configuration files here:
    # Agents: https://docs.crewai.com/concepts/agents#yaml-configuration-recommended
    # Tasks: https://docs.crewai.com/concepts/tasks#yaml-configuration-recommended
    
    # If you would like to add tools to your agents, you can learn more about it here:
    # https://docs.crewai.com/concepts/agents#agent-tools
    @agent
    def researcher(self) -> Agent:
        return Agent(
            config=self.agents_config['researcher'], # type: ignore[index]
            verbose=True
        )

    @agent
    def reporting_analyst(self) -> Agent:
        return Agent(
            config=self.agents_config['reporting_analyst'], # type: ignore[index]
            verbose=True
        )

    # To learn more about structured task outputs,
    # task dependencies, and task callbacks, check out the documentation:
    # https://docs.crewai.com/concepts/tasks#overview-of-a-task
    @task
    def research_task(self) -> Task:
        return Task(
            config=self.tasks_config['research_task'], # type: ignore[index]
        )

    @task
    def reporting_task(self) -> Task:
        return Task(
            config=self.tasks_config['reporting_task'], # type: ignore[index]
            # output_file will be set dynamically in the crew_with_output_file method
        )

    @crew
    def crew(self) -> CrewAI:
        """Creates your AI crew"""
        # To learn how to add knowledge sources to your crew, check out the documentation:
        # https://docs.crewai.com/concepts/knowledge#what-is-knowledge

        return CrewAI(
            agents=self.agents, # Automatically created by the @agent decorator
            tasks=self.tasks, # Automatically created by the @task decorator
            process=Process.sequential,
            verbose=True,
            # process=Process.hierarchical, # In case you wanna use that instead https://docs.crewai.com/how-to/Hierarchical/
        )
    
    def crew_with_output_file(self, output_file: str) -> CrewAI:
        """
        Creates your AI crew with a specific output file.
        
        Args:
            output_file: Path where the final report will be saved
            
        Returns:
            CrewAI: Configured crew with custom output file
        """
        # Get agents
        agents = [self.researcher(), self.reporting_analyst()]
        
        # Create tasks with custom output file using utility function
        tasks = create_crew_tasks_with_output(
            self.tasks_config, # type: ignore[attr-defined]
            self.research_task,
            output_file
        )
        
        return CrewAI(
            agents=agents,
            tasks=tasks,
            process=Process.sequential,
            verbose=True,
        )
