import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { db } from '../../config/db';
import { users, logs } from '../../db/schema';
import { eq } from 'drizzle-orm';
import crypto from 'crypto';
import { env } from '../../config/env';
import { AppError } from '../../middlewares/errorHandler';
import { UserPayload } from '../../middlewares/auth';

export class AuthService {
  private generateAccessToken(user: { id: string; email: string; role: 'USER' | 'ADMIN' }): string {
    return jwt.sign(
      { id: user.id, email: user.email, role: user.role } as UserPayload,
      env.JWT_SECRET,
      { expiresIn: '1h' }
    );
  }

  private generateRefreshToken(user: { id: string; email: string; role: 'USER' | 'ADMIN' }): string {
    return jwt.sign(
      { id: user.id, email: user.email, role: user.role } as UserPayload,
      env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );
  }

  async register(email: string, passwordHash: string, role: 'USER' | 'ADMIN' = 'ADMIN') {
    const existingUsers = await db.select().from(users).where(eq(users.email, email)).limit(1);
    const existingUser = existingUsers[0];

    if (existingUser) {
      throw new AppError('Email already registered', 400, 'EMAIL_EXISTS');
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(passwordHash, salt);

    const userId = crypto.randomUUID();
    const [user] = await db.insert(users).values({
      id: userId,
      email,
      passwordHash: hashedPassword,
      role,
    }).returning();

    // Log the registration event
    await db.insert(logs).values({
      id: crypto.randomUUID(),
      userId: user.id,
      action: 'register',
      detail: { email: user.email, role: user.role },
    });

    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    return {
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        credits: user.credits,
        subscriptionStatus: user.subscriptionStatus,
        subscriptionExpiresAt: user.subscriptionExpiresAt,
        createdAt: user.createdAt,
      },
      accessToken,
      refreshToken,
    };
  }

  async login(email: string, passwordHash: string) {
    const foundUsers = await db.select().from(users).where(eq(users.email, email)).limit(1);
    const user = foundUsers[0];

    if (!user) {
      throw new AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
    }

    const isMatch = await bcrypt.compare(passwordHash, user.passwordHash);
    if (!isMatch) {
      throw new AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
    }

    // Log the login event
    await db.insert(logs).values({
      id: crypto.randomUUID(),
      userId: user.id,
      action: 'login',
      detail: { email: user.email },
    });

    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    return {
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        credits: user.credits,
        subscriptionStatus: user.subscriptionStatus,
        subscriptionExpiresAt: user.subscriptionExpiresAt,
        createdAt: user.createdAt,
      },
      accessToken,
      refreshToken,
    };
  }

  async refresh(token: string) {
    try {
      const decoded = jwt.verify(token, env.JWT_REFRESH_SECRET) as UserPayload;
      const foundUsers = await db.select().from(users).where(eq(users.id, decoded.id)).limit(1);
      const user = foundUsers[0];

      if (!user) {
        throw new AppError('User not found', 401, 'UNAUTHORIZED');
      }

      const accessToken = this.generateAccessToken(user);
      const newRefreshToken = this.generateRefreshToken(user);

      return {
        accessToken,
        refreshToken: newRefreshToken,
      };
    } catch (error) {
      throw new AppError('Invalid or expired refresh token', 401, 'INVALID_REFRESH_TOKEN');
    }
  }

  async changePassword(userId: string, oldPassword: string, newPassword: string) {
    const foundUsers = await db.select().from(users).where(eq(users.id, userId)).limit(1);
    const user = foundUsers[0];

    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }

    const isMatch = await bcrypt.compare(oldPassword, user.passwordHash);
    if (!isMatch) {
      throw new AppError('Password lama salah', 400, 'INCORRECT_OLD_PASSWORD');
    }

    if (newPassword.length < 6) {
      throw new AppError('Password baru minimal 6 karakter', 400, 'WEAK_PASSWORD');
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await db.update(users).set({ passwordHash: hashedPassword }).where(eq(users.id, userId));

    await db.insert(logs).values({
      id: crypto.randomUUID(),
      userId: user.id,
      action: 'change_password',
      detail: { success: true },
    });
  }
}
