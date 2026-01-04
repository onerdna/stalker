package com.onerdna.stalker;

import android.util.Log;

import androidx.annotation.Keep;

import java.io.BufferedReader;
import java.io.InputStreamReader;

@Keep
public class BinderService extends IBinderService.Stub {

    @Keep
    public BinderService() {
        Log.i("BinderService", "Init called");
    }

    @Keep
    @Override
    public String runCommand(String command) {
        StringBuilder outputBuilder = new StringBuilder();
        Process process = null;

        try {
            process = Runtime.getRuntime().exec(new String[]{"sh", "-c", command});

            // Read standard output
            BufferedReader input = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = input.readLine()) != null) {
                outputBuilder.append(line).append("\n");
            }

            // Read error output
            BufferedReader error = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            while ((line = error.readLine()) != null) {
                outputBuilder.append(line).append("\n");
            }

            process.waitFor();
        } catch (Exception e) {
            outputBuilder.append("Error: ").append(e.getMessage());
        } finally {
            if (process != null) {
                process.destroy();
            }
        }

        return outputBuilder.toString().trim();
    }

    @Keep
    @Override
    public void destroy() {
        Log.d("BinderService", "Destroy called");
    }
}
