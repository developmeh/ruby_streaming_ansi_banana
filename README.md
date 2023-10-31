# Dancing ASCII Banana Sinatra App 🍌💃

This application is a Sinatra-based web service with a `/live` endpoint. When invoked from `curl`, it displays a dancing ASCII banana. It uses the standard Sinatra setup for its URL configuration.

![Recording 2023-10-30 at 23 31 52](https://github.com/developmeh/ruby_streaming_ansi_banana/assets/159591/04d8efa3-a3bc-477e-84fe-1eac93b81a74)


## Getting Started

Before running the application, make sure you have Ruby, Bundler, and `make` installed on your system.

This project provides a nix flake for dependencies and the convenience of direnv

### Installing Dependencies

To install the required gems for the application, run:

```bash
make install
```

This will use Bundler to install all necessary dependencies.

### Serving the Application

To serve the application, use:

```bash
make serve
```

Once the application is running, you can access the /live endpoint. If using curl, you should see a dancing ASCII banana in your terminal.

---

Enjoy the dancing banana!

---

## Technical Insights: ANSI and Chunk Encoding

### Clearing the Screen with ANSI

This application leverages ANSI escape codes, which are sequences of characters that instruct the terminal to perform specific tasks. One of these tasks is to clear the screen, providing a clean slate for our dancing banana.

The ANSI sequence used to clear the screen is `\033[2J\033[3J\033[H`

In the context of this application, we utilize ANSI escape sequences, which are a standard for manipulating the state of a terminal or command prompt. Specifically, the application sends an ANSI sequence to clear the terminal screen when viewed with tools like `curl`.

For instance, the sequence `\033[2J` clears the entire screen and `\033[H` sets the cursor to the home position (top-left corner). By using these sequences in combination, we can achieve a screen-clearing effect in the terminal. This is particularly useful when updating the terminal view with new content, like our dancing banana!

### Chunked Encoding

HTTP chunked transfer encoding is a streaming data transfer mechanism available in version 1.1 of the HTTP protocol. Instead of sending data as a single continuous stream, which requires the sender to know the total length beforehand, chunked encoding allows data to be broken into a series of "chunks". Each chunk is preceded by its size in bytes, allowing the receiver to reassemble the full content.

In our application, chunked encoding plays a vital role as it allows us to continuously send and update data (like the dancing ASCII banana) to the client without having to determine the content's total length in advance. This is especially valuable for live or real-time data streams where the total content size is unpredictable.
