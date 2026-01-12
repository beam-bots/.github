# Contributing to Beam Bots

## Welcome!

We welcome contributions of all sizes, from typos and documentation improvements to bug fixes and features. Check the issue tracker or join the [Discord](https://discord.gg/McZmMaR34P) to see how you can help. Make sure to read the rules below as well.

## Contributing to Documentation

Documentation contributions are one of the most valuable kinds of contributions you can make! Good documentation helps everyone in the community understand and use Beam Bots more effectively.

### Protocol for Documentation Improvements

**We prefer Pull Requests over issues for documentation improvements.** Here's why and how:

- **Make a PR directly** - This is the preferred approach! Even if you're not 100% sure about your changes, submitting a PR with your suggested improvement is much more helpful than opening an issue to discuss it.
- **PRs represent tangible suggestions** - They're easy to review, approve, reject, or modify. We can see exactly what you're proposing and act on it quickly.
- **Issues are okay too** - If you're really unsure or want to discuss a larger documentation restructuring, you can open an issue first. But for most cases, just make the PR!
- **Don't worry about rejection** - If a PR doesn't fit or needs changes, we'll provide feedback or close it with explanation. This is much more efficient than back-and-forth discussion in issues.

### Making Documentation Changes

The best way to contribute to documentation is often through GitHub's web interface, which allows you to make changes without having to clone the code locally:

**For Guides:**
- While viewing any guide on the documentation website, look for the `</>` button in the top right of the page
- Clicking this button will take you directly to GitHub's editing interface for that file

**For Module Documentation:**
- When viewing module documentation, the `</>` button will also be in the top right of the page

**For Function Documentation:**
- When viewing individual functions, you'll find the `</>` button next to the function header

Once you click the `</>` button, GitHub will:
1. Fork the repository for you (if you haven't already)
2. Open the file in GitHub's web editor
3. Allow you to make your changes directly in the browser
4. Help you create a pull request with your improvements

This workflow makes it incredibly easy to fix typos, clarify explanations, add examples, or improve any part of the documentation you encounter while using Beam Bots.

### Important Note About DSL Documentation

**DSL documentation cannot be edited directly on GitHub.** The documentation you see for DSL options (like those for `BB`) is generated from the source code of the DSL definition modules.

For example, if you want to improve documentation for `BB` options, you need to edit the source code in the `BB.Dsl` module, not the generated documentation files. The DSL documentation is automatically generated from the DSL attributes and option definitions in these modules.

When making DSL documentation improvements, make sure to:
1. Edit the appropriate DSL definition module (not generated docs)
2. Test that your changes generate correctly by running `mix spark.cheat_sheets` and then `mix docs`.

## Feature Proposals

Feature requests and larger changes are tracked in the [proposals repository](https://github.com/beam-bots/proposals).
Before working on a significant feature, please open a proposal there first. The best proposals focus on the
*use case* rather than the implementation details.

For smaller enhancements or bug fixes, opening an issue in the relevant repository is fine.

## Rules

* We have a zero tolerance policy for failure to abide by our code of conduct. It is very standard, but please make sure
  you have read it.
* Issues may be opened to ask questions or to file bugs. Feature requests should go to the [proposals repository](https://github.com/beam-bots/proposals).
* Before starting work, please comment on the issue and/or ask in the Discord if anyone is handling an issue.

## Local Development & Testing

### Setting Up Your Development Environment

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/your-username/bb.git
   cd bb
   ```

2. **Install dependencies:**
   ```bash
   mix deps.get
   ```

3. **Compile the project:**
   ```bash
   mix compile
   ```

### Running Tests and Checks

Before submitting any pull request, please run the full test suite and quality checks locally:

```bash
mix check --no-retry
```

This command runs a comprehensive suite of checks including:
- Compilation
- Tests
- Code formatting (including `spark.formatter`)
- Credo (static code analysis)
- Dialyzer (type checking)
- Documentation generation and validation
- REUSE compliance

### Testing with Your Application

If you want to test your changes with your own application, you can use Beam Bots as a local dependency. In your application's `mix.exs`, replace the hex dependency with a path dependency:

```elixir
defp deps do
  [
    # Replace this:
    # {:bb, "~> 0.1"}

    # With this (adjust path as needed):
    {:bb, path: "../bb"},

    # Your other dependencies...
  ]
end
```

Alternatively, use the `BB_VERSION` environment variable:

```bash
BB_VERSION=local mix deps.get && mix test
```

This allows you to:
- Test your changes against real-world usage
- Verify that your changes don't break existing functionality
- Develop features iteratively with immediate feedback

Testing in your own application is not sufficient - you must also include automated tests.

### Development Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and write tests

3. **Run the full check suite:**
   ```bash
   mix check --no-retry
   ```

4. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Add feature description"
   ```

5. **Push and create a pull request**

### Common Development Tasks

- **Generate documentation:** `mix docs`
- **Run specific test file:** `mix test test/path/to/test_file.exs`
- **Run specific test at line:** `mix test test/path/to/test_file.exs:42`
- **Check formatting:** `mix format --check-formatted`
- **Run tests with coverage:** `mix test --cover`
