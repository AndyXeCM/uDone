# uDone
U've done a lot

Crafted for Apple Swift Student Challenge 2026, but failed.

Following are some screenshots showing the app making, handling and failing process.

<img width="1281" height="792" alt="8121774585808_ pic_hd" src="https://github.com/user-attachments/assets/faf781b4-83e0-4031-8726-20f196bb3f8c" />

<img width="2360" height="1640" alt="8071774585804_ pic_hd" src="https://github.com/user-attachments/assets/f46879eb-5cf8-424f-b6bb-68d33b89b413" />

<img width="2360" height="1640" alt="8081774585805_ pic_hd" src="https://github.com/user-attachments/assets/9aabb02d-bfce-46c6-9d7a-7a2c82f33d2e" />

![8091774585806_ pic_hd](https://github.com/user-attachments/assets/6b623651-aec5-4577-9c01-159fb2c6ed16)

<img width="2360" height="1640" alt="8101774585807_ pic_hd" src="https://github.com/user-attachments/assets/57046494-3070-4d62-9cb0-a64f492ec200" />

<img width="977" height="595" alt="8111774585808_ pic_hd" src="https://github.com/user-attachments/assets/cad24bfe-4d48-411e-a5d1-81c7925dd739" />

<img width="1640" height="2360" alt="8141774585811_ pic_hd" src="https://github.com/user-attachments/assets/52399bb3-3f70-49a5-87c9-a635a01fd7f2" />

<img width="1640" height="2360" alt="8151774585812_ pic_hd" src="https://github.com/user-attachments/assets/9941c638-ce96-4192-8cdd-204eb50cb6cf" />

Essays about the app:

> uDone notes

Before entering ninth grade, my teacher gave us a piece of advice: upcoming studies would be incredibly busy, and without recording our daily experiences, we would likely leave a hollow sense of accomplishing nothing. In our fast-paced study environment with tons of work to do, her words deeply resonated with me.
I initially tried beautiful physical notebooks. While they allowed me to freely doodle, the was actually inconvenient—an expensive journal only lasted a month and lacked portability. I didn't keep up the record for long because after a few months, I stopped. Talking with classmates, I realized we shared the desire to document our lives but struggled to find a convenient, affordable tool. Most digital life-recording apps are rigid, restricting users to typed text, making it hard to express creativity and causing us to lose motivation.
These shared struggles inspired uDone. Utilizing the Apple Pencil, it lets people unleash their creativity conveniently. The app also had a streak feature effectively helps users maintain the habit of keeping records. Generally, I wanted to provide people with a practical, low-cost, free-form tool, empowering everyone to creatively preserve their daily footprints and no longer fear the passage of time.


I believe uDone can benefit anyone who desires to document their daily lives, but deterred by flexibility, costs, and lack of motivation. Students, professionals and visual creatives are typical audience groups with the those characteristics.
For students and others who have many tasks to complete and limited budgets, uDone has the initial purpose of solving the cost and portability issues of physical journals. It recreates the tactile joy of premium notebooks without the recurring expense or bulkiness, making journaling highly practical and accessible.
For professionals and creatives, it provides a much-needed creative outlet. After typing all day, rigid text-based apps feel like a chore. By utilizing the Apple Pencil on free-form canvases, uDone allows users to visually express their "Mood, Things, and Thoughts" through sketches and handwriting, offering a mindful and highly personal way to reflect.
Finally, uDone helps anyone struggling to maintain the habit. Writing lengthy diary entries can be intimidating. uDone lowers this barrier, as even a quick doodle counts. Combined with the streak feature, it provides that essential extra push of motivation, turning life recording into a low pressure action, engaging daily routine.

My initial vision for uDone was to ensure that visually impaired users could independently document their lives. Aiming at this goal, accessibility drove my design process across three dimensions:
Visual: I meticulously optimized VoiceOver for seamless navigation. I grouped UI elements using .accessibilityElement(children: .ignore) with dynamic .accessibilityLabel. Since a raw canvas is invisible to screen readers, I introduced readable semantic stickers (emojis, ratings, tags) so visually impaired users can "draw" and VoiceOver can read their entries perfectly.
Cognitive: Traditional journaling can overwhelm users with ADHD or dyslexia. uDone lowers cognitive load by breaking the day into three simple visual prompts. Furthermore, the app's straightforward operation logic allows users to intuitively view and share their daily lives without navigating complex menus.
Motor: While drawing inherently requires fine motor skills, I integrated a tap-to-place sticker system to support motor accessibility. This allows users experiencing hand tremors or motor fatigue to complete a basic entry using just a few simple taps. However, I am fully aware that this alternative input is currently insufficient for a fully detailed record. I plan to significantly improve this design in future updates, striving to empower even more people to effortlessly document their lives.

I integrated two AI tools into my workflow, each serving different purposes. I used Xcode’s built-in ChatGPT primarily for straightforward code debugging and quick syntax interpretation. Meanwhile, I relied on Google Gemini for broader Swift learning and tackling complex app challenges. For instance, I consulted these AI tools to figure out how to precisely position floating elements and curved arrows in my AboutView, and how to properly extract and serialize Apple Pencil stroke data into images within my DataModel.
The most memorable learning moment occurred while handling image exports in Dark Mode. I wanted exported canvas images to always feature a white background. However, strokes drawn in Dark Mode with white color would become completely invisible when placed on a white export background.
I asked Gemini for a solution, and it taught me a clever workaround by temporarily overriding the system environment using UITraitCollection(userInterfaceStyle: .light).performAsCurrent and .environment(\.colorScheme, .light) strictly for the rendering view.
This experience taught me a vital programming mindset: sometimes, solving a complex bug isn't about altering the core data, but rather shifting perspectives, such as temporarily "disguising" the app's environment state to trick the rendering engine into generating the desired output.

To bring uDone to life, I utilized Apple's hardware ecosystem alongside some software frameworks.
Hardware-wise, I coded on my MacBook and deployed to my iPad for real-time debugging. I also invited my classmates and friends to test the app on their iPads. Their hands-on usage provided invaluable feedback, telling me exactly what else needed optimization to perfect the user experience.
PencilKit is the core engine of uDone, chosen to replace rigid text boxes with canvas. The user interface is powered by SwiftUI for sure, leveraging its declarative syntax and native animations to create fluid interface transitions. Also, guided by AI, I implemented UIKit Bridging to integrate PKCanvasView. This bypassed SwiftUI's native limitations, giving me granular control to configure a transparent canvas for layering custom stickers and properly bind the PKToolPicker for the Apple Pencil. In addition, I use a zoomable UIScrollView for viewing archives, and the native share sheet.
Finally, for data persistence, I chose FileManager combined with Codable. Serializing strokes and sticker coordinates into local JSON files is lightweight and ensures offline functionality. Most importantly, it guarantees that users' highly personal daily journals remain strictly on-device for maximum privacy.

While I’m quite new to swift development, I am passionate to use my broader tech skills to empower my community. Last semester, my English class struggled with the complex plot and dense personalities of the novel Malafrena. Using my web development skills and with the help of AI, I built an open-source website featuring interactive, graphical interface of the storylines and characteristics of the novel. This tool made the dense material more accessible. Consequently, my classmates who were previously overwhelmed could easier follow the narrative and participate more in our class discussions. (deployment:https://andyxecm.github.io/Malafrena/) Furthermore, recognizing the growing trend and my interest around artificial intelligence, a friend and I co-founded a seminar about AI at our school. I personally gave principles and taught practical, hands-on usage skills of AI in those seminars. It was rewarding to lead my peers to understand the principles and better integrate AI into their daily learning workflows, and I will never forget when they said "wow" when really knowing how AI works. I am making efforts as I always believe that the ultimate goal of learning technology is to make people's lives better, no matter by passing on knowledge or building better tools to gain benefits.

A note on experiencing uDone: To truly capture the authentic, tactile joy of handwriting, uDone is best experienced on an iPad paired with an Apple Pencil.
My  Journey: In third grade, driven by pure curiosity, I typed my first line of code into PowerShell on an old family PC. Later, as a reward for good grades, my mom gifted me my very first personal computer: a MacBook.
That MacBook brought a classic Apple quote to life for me: "Give people wonderful tools, and they'll do wonderful things." From building Scratch games in elementary school, to creating web blogs, and now submitting my Swift Student Challenge project, this MacBook has been my constant companion. It is the "wonderful tool," in my mind, empowering me to create my own "wonderful things."
Looking Forward: This challenge is just a starting point. My future goal is to publish uDone on the App Store to help more people in need creatively document their lives. Thank you so much for your time in reviewing my code and reading my story!

Primary Personal Blog: https://743.world
(Note: This blog contains my most in-depth writing and project documentation. It is primarily in Chinese, so I highly recommend using Safari's built-in translation feature.)

Literature Visualizer (Malafrena): https://andyxecm.github.io/Malafrena/help.html
(Note: The live reading assistance system I built to help my classmates visually understand complex novel plots, as mentioned in my community impact essay. Also recommending to translate via safari)

Web Project (Hamster Flight Simulator): https://hamfs.io
(Note: A flight simulator website I co-developed with a friend to share our passion for aviation. May need a bit of translation)

English Tech Blog: https://aoodyconcorde.com
(Note: My newly established English blog, currently a work in progress.)
