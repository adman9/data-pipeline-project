
FROM python:3.11-slim

# extract requirements.txt from poetry
RUN pip install poetry
ADD pyproject.toml .
RUN poetry install
RUN poetry export --without-hashes --format=requirements.txt > requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Run app.py when the container launches
CMD ["python", "main.py"]