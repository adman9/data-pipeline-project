FROM python:3.11

# extract requirements.txt from poetry
RUN pip install poetry
ADD pyproject.toml README.md /app/
WORKDIR /app
COPY . /app/
RUN poetry install
RUN poetry export --without-hashes --format=requirements.txt > requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080

# Run app.py when the container launches
CMD ["python", "main.py"]