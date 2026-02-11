# Smart Hearing Assistant – AI Noise Segregation App

## Overview
Smart Hearing Assistant is a Flutter-based mobile application designed to help users distinguish **important auditory information from background noise** in real time.  
The app captures surrounding audio, sends structured data to an AI workflow, filters irrelevant noise using an LLM, prioritizes meaningful information, and delivers the processed results back to the user.

This project combines **Mobile Development, AI Processing, Backend Automation** into a single intelligent assistive system.

---

## Problem Statement
People with hearing difficulties or those in noisy environments often struggle to focus on meaningful sounds such as speech, instructions, or alerts. Traditional hearing tools amplify all sounds equally, including noise.

**Goal:**  
Build an intelligent system that identifies and prioritizes useful audio while suppressing random or irrelevant noise.

---

## Solution
A real-time AI-assisted hearing application that:

- Captures environmental audio
- Sends requests to an AI workflow
- Segregates noise vs meaningful instructions
- Stores prioritized data in the cloud
- Fetches filtered results instantly in the mobile app

---

## Tech Stack

### Frontend (Mobile)
**Flutter**
- Cross-platform UI development
- Microphone/audio capture
- HTTP communication with backend
- Async real-time data handling

### Backend Automation
**n8n**
- Visual workflow orchestration
- Handles incoming HTTP requests
- Triggers AI/LLM processing
- Connects services without heavy backend code

### AI / Processing Layer
**Large Language Model (LLM)**
- Semantic analysis of instructions
- Noise filtering
- Priority classification
- Context understanding

### Database / Backend Services
**Supabase**
- Cloud database storage
- Real-time data retrieval
- REST APIs
- Scalable backend infrastructure

---

## Architecture

Flutter App
↓
HTTP Request
↓
n8n Workflow
↓
LLM Noise Segregation
↓
Supabase Database
↓
Flutter Fetch & Display


**Architecture Style:**
- Event-Driven
- Microservice-Inspired
- AI-Assisted Processing Pipeline

---

## Key Features

- Real-Time Audio Processing
- AI-Driven Noise Filtering
- Priority-Based Information Sorting
- Cloud Data Synchronization
- Cross-Platform Mobile Support
- Low-Latency Communication

---

## Core Workflow

1. User opens the Flutter app.
2. App captures surrounding audio.
3. Audio/instruction data is sent via HTTP request.
4. n8n workflow triggers LLM processing.
5. AI segregates noise vs meaningful content.
6. Filtered and prioritized data is stored in Supabase.
7. Flutter app fetches and displays the processed results in real time.

---

## Engineering Challenges Addressed

| Challenge | Solution |
|--------|---------|
| Noise Identification | LLM semantic filtering |
| Real-Time Speed | Async networking & streams |
| Backend Complexity | n8n automation workflows |
| Data Prioritization | Supabase indexing |
| Cross-Platform Support | Flutter framework |

---

## Advanced Concepts Demonstrated

- Real-Time Systems
- Workflow Orchestration
- AI Classification Pipelines
- Event-Driven Architecture
- Cloud-Based Data Handling
- Human Assistive Technology Design

---

## Use Cases

- Hearing assistance
- Noisy environments (public places, offices)
- Instruction filtering
- Accessibility enhancement
- Smart audio tools

---

## Future Improvements

- Edge AI processing for offline use
- Audio waveform visualization
- User personalization & learning
- Speech-to-Text integration
- Multi-language support
- Reduced latency with streaming APIs

---

## Why This Project Matters

- Solves a real-world accessibility problem
- Combines Mobile + AI + Backend + Cloud
- Demonstrates full-stack and system design skills
- Scalable and production-ready architecture
- Strong portfolio and interview-level project

---

## Summary

Smart Hearing Assistant is an AI-powered mobile application that intelligently filters environmental audio to highlight meaningful information. By integrating Flutter, n8n workflows, LLM processing, and Supabase cloud services, the project showcases a modern, scalable, and real-time assistive technology system.
